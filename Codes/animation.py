# -*- coding: utf-8 -*-
"""
Matplotlib animations for MITgcm data

Made for netCDF4.Dataset (mnc)
-Needs ffmpeg to save directly to disk. Alternatively, save the FuncAnimation version with matplotlib.

@author: pascalb

Examples:
>>> import netCDF4 as nc
>>> data = nc.Dataset('dynDiag.nc') # Où dynDiag.nc contient le champ ET les dimensions requis
                                    # pour TOUTES les tiles (i.e. utiliser gluemncbig)
>>> ani = Animation2D.imshow(data, 'UVEL', iy='mid', usemeters=True, istep=2+3j)

Crée une animation basé sur imshow de la vitesse U (UVEL), pour la tranche xz du centre. Les unités horizontales sont en mètres.
Une itération sur deux (dans data) est utilisée et les 3 snapshots autour de i sont moyennés pour l'image i.

>>> aniF = ani.FuncAnimation(interval=30) # Crée un objet d'animation Matplotlib, chaque image dure 30 ms
>>> plt.show()

>>> ani.save('animation.mp4', fps=30) # Sauve l'animation en vidéo mp4.
"""
import itertools
import numpy as np
import subprocess as proc
from pathlib import Path
from datetime import timedelta
import matplotlib.pyplot as plt
import matplotlib.animation as anim
from matplotlib.patches import Rectangle
from matplotlib import rcParams  # , rc_context
from .common import CommandOutputStreams

class Animation2D(object):
    """Convenient Object to create simple 2D animations from MITgcm netcdf data.
        
    Class methods:
        imshow, contour : create an Animation2D object with an imshow/contour plot.

    Methods:
        _set_axes_text : Draw the axes texts (labels, title). To be added to any homemade ani.func, if it clears the axes.
        makecolorbar : To be called after the main plot object creation, creates the colorbar.
        FuncAnimation : Returns a matplotlib.animation.FuncAnimation object
        save : Saves to file using the homemade FFMpeg PIPE writer.

    Attributes:
        fig, ax, titletext : the figure, main axes and the title handle
        data, key : The main data set and the key of the variable to plot
        tslice, XYZslice : The slices to be animated
        values : data[key][[tslice] + XYZslice] -> only the values that will be plotted.
        axes : A list of the two dimensions of the plane
        extent : The left, right, bottom, top corners in data coordinates (for imshow)
        indexes : The data's frame indexes to be plotted.
        vmin, vmax, cmap : The min and max values for the color limit and the colormap used.
        name : The name of the variable shown (a user-passed name, the long_name attribute of the var or the key)
        units : The units of the variable (a user-passed string or the units attribute of the var)

    The init doesn't create the main plot object and the updating function. If you are not using the class methods,
        you must set the 'im' and the 'func' attributes. Call makecolorbar() only after setting im.
    """

    def __init__(self, dataset, key, fs=(6, 4.5), fcolor='gainsboro',
                 clip=1, vmin=None, vmax=None, divergent=True, cmap=None,
                 istep=1+1j, istart=0, istop=None, ix=None, iy=None, iz=None, size=None,
                 units=None, name=None, title="", walls=None,
                 usemeters=False, **unusedkwargs):
        """Initialize the figure and the axes and a bunch of other things.

        Args:
            fs, fcolor : The figure size and its facecolor
            vmin, vmax : The limits of the colormap. If None they are computed from the data as
                            vmin = clip * values.min() and vmax = clip * values.max()
                         If divergent is True, than vmin and vmax are set to ±max(vmin, vmax)
            istart, istop, istep : Time slicing, default to the complete dataset. 
                                   istep can be complex : its imaginary part is the number of frames to average together for one animation frame.
            ix, iy, iz : One of those must be an int index of the slice to show. (Ex: XY-layer at z=0 : iz=0, ix=None, iy=None)
                         Can be one of 'top'/'beg' (i.e. 0), 'end'/'bot' (i.e. -1) or 'mid': len(coord)//2
            units, name : Text to show instead of the default values in the dataset.
            title : The base title. It will be appended by the iteration number and the corresponding time.
            walls : Whether to draw channel or box walls. None, 'x', 'y' or 'xy'
            usemeters : Whether to use meters as horizontal units or not (i.e. km by divding by 1000) (z is always in meters or units)

        Create with a classmethod (imshow or contour), or by the init as `ani = Animation2D(data, key, **args)`
        The returned object has empty fields `im` and `func` to be set.
            im : the main drawable (imshow, contour, pcolor...)
            func : an update function receiving 2 args :*n*, the frame number, and this object.
                   The data's frame number can be retrieved with `ani.indexes[n]`
        """

        self.dataset = dataset.variables
        self.data = dataset.variables[key]
        self.key = key
        self.iavg = np.imag(istep) or 1
        if istop is None:
            istop = self.data.shape[0] - self.iavg//2
        self.tslice = slice(istart, int(istop), int(np.real(istep)))
        self.indexes = range(self.data.shape[0])[self.tslice]

        dimprops = [[3, ix], [2, iy], [1, iz]]
        for dim in dimprops:
            if dim[1] == 'mid':
                dim[1] = self.data.shape[dim[0]]//2
            elif dim[1] == 'top' or dim[1] == 'beg':
                dim[1] = 0
            elif dim[1] == 'bot' or dim[1] == 'end':
                dim[1] = -1

        self.XYZslice = [slice(None) if dim is None else dim for i, dim in reversed(dimprops)]

        # Compute color limits
        if vmax is None or isinstance(vmax, str):
            if vmax == 'end':
                values = self.data[[self.indexes[-100:]] + self.XYZslice]
            elif vmax == 'mid':
                values = self.data[[self.indexes[len(self.indexes)//2 - 50: len(self.indexes)//2 + 50]] + self.XYZslice]
            elif vmax == 'beg':
                values = self.data[[self.indexes[:100]] + self.XYZslice]
            else:
                values = self.data[[self.indexes[::np.ceil(len(self.indexes)/100).astype(int)]] + self.XYZslice]
            vmax = values.max()*clip
            vmin = values.min()*clip

        if divergent:
            self.vmax = vmax if vmin is None else np.abs([vmin, vmax]).max()
            self.vmin = -self.vmax
        else:
            self.vmin = vmin
            self.vmax = vmax
        self.cmap = cmap or plt.cm.RdBu if divergent else plt.cm.viridis

        self.axes = []
        for i, dim in dimprops:
            if dim is None:
                if self.data.dimensions[i] in self.dataset:
                    self.axes.append({'values': self.dataset[self.data.dimensions[i]][:]/(1e3 if not usemeters and i != 1 else 1), 'name': self.dataset[self.data.dimensions[i]].name[0], 'units': ('km' if not usemeters and i != 1 else 'm')})
                elif self.data.dimensions[i].startswith('Zm') and 'diag_levels' in self.dataset:
                    self.axes.append({'values': self.dataset['diag_levels'][:], 'name': 'level indices', 'units':'-'})
                else:
                    self.axes.append({'values': np.arange(self.data.shape[i]), 'name': 'data indices', 'units':'-'})

        self.extent = size or [self.axes[i]['values'][j] for i, j in [(0,0), (0, -1), (1, 0), (1, -1)]]

        self.fig, self.ax = plt.subplots(figsize=fs, facecolor=fcolor)

        self.units = units or self.data.units
        self.name = name or (key.lower() if not hasattr(self.data, 'long_name') else self.data.long_name.replace('_', ' ').capitalize())
        if self.name.startswith('\\'):  # LaTeX math titles
            self.name = '${}$'.format(self.name)

        self.kwargs = unusedkwargs
        self.walls = walls or ''

        self.title = title
        self._set_axes_text()

        self.im = None
        self.func = None

    def _set_axes_text(self):
        self.ax.set_ylabel("{} [{}]".format(self.axes[1]['name'].lower(), self.axes[1]['units'])
        self.ax.set_xlabel("{} [{}]".format(self.axes[0]['name'].lower(), self.axes[0]['units'])

        self.titletext = self.ax.set_title(self.title)

        if 'x' in self.walls:
            self.ax.add_patch(Rectangle(self.extent[0], self.extent[2]-2), self.extent[1]-self.extent[0], 2, color='k')
            self.ax.add_patch(Rectangle(self.extent[0], self.extent[3]-1), self.extent[1]-self.extent[0], 2, color='k')
            self.ax.set_ylim(self.extent[2]-2, self.extent[3]+1)
        if 'y' in self.walls:
            self.ax.add_patch(Rectangle(self.extent[0]-2, self.extent[2]), 2, self.extent[3]-self.extent[2], color='k')
            self.ax.add_patch(Rectangle(self.extent[1]-1, self.extent[2]), 2, self.extent[3]-self.extent[2], color='k')
            self.ax.set_xlim(self.extent[0]-2, self.extent[1]+1)

    def makecolorbar(self):
        """Create a colorbar with the mappable in self.im."""
        self.cb = self.fig.colorbar(mappable=self.im)
        self.cb.set_label(f"{self.name} [{self.units}]")

    def _update_title(self, n):
        """Update the title by appending "Iter 000000, 00:00:00" to the basetitle."""
        # n = self.indexes[n]
        time = timedelta(seconds=self.dataset['T'][n])
        niter = int(self.dataset['iter'][n])
        self.titletext.set_text(self.title + f" Iter {niter:6.0f} {time.days: 5d}d {time.seconds//3600:02d}:{(time.seconds % 3600)//60:02d}:{time.seconds % 60:02d}")

    @classmethod
    def imshow(cls, data, key, **args):
        """Create an Animation2D object with an imshow plot of key."""
        ani = cls(data, key, **args)

        ani.im = ani.ax.imshow(ani.data[[0] + ani.XYZslice], cmap=ani.cmap, vmin=ani.vmin, vmax=ani.vmax, extent=ani.extent[:4], animated=True)
        ani.makecolorbar()

        def animate(n, frame, ani):
            ani.im.set_data(frame)
            return ani.im,

        ani.func = animate

        return ani

    @classmethod
    def contour(cls, data, key, nval=11, fill=True, **args):
        """Create an Animation2D with a contour plot of key."""
        args['divergent'] = args.get('divergent', False)
        ani = cls(data, key, **args)

        ani.kwargs['levels'] = np.linspace(ani.vmin, ani.vmax, nval)
        ani.kwargs['fill'] = fill

        if fill:    
            ani.im = ani.ax.contourf(ani.axes[0]['values'], ani.axes[1]['values'], ani.data[[0] + ani.XYZslice], ani.kwargs['levels'], cmap=ani.cmap, extend='both')
        else:
            ani.im = ani.ax.contour(ani.axes[0]['values'], ani.axes[1]['values'], ani.data[[0] + ani.XYZslice], ani.kwargs['levels'], cmap=ani.cmap, extend='both')

        ani.makecolorbar()

        def animate(n, frame, ani):
            ani.ax.clear()
            if fill:
                ani.im = ani.ax.contourf(ani.axes[0]['values'], ani.axes[1]['values'], frame, ani.kwargs['levels'], cmap=ani.cmap, extend='both')
            else:
                ani.im = ani.ax.contour(ani.axes[0]['values'], ani.axes[1]['values'], frame, ani.kwargs['levels'], cmap=ani.cmap, extend='both')
            ani._set_axes_text()
            ani.cb.update_normal(ani.im)
            return ani.ax, ani.im, ani.cb
        ani.func = animate

        return ani

    def _get_frames(self, cycle=False):
        """Returns a generator of all animation frames.

        If cycle is True, repeats endlessly.
        """
        iterator = self.indexes
        if cycle:
            iterator = itertools.cycle(self.indexes)
        for n in iterator:
            if self.iavg == 1:
                yield n, self.data[[n] + self.XYZslice]
            else:
                yield n, np.mean(self.data[[slice(n-self.iavg//2, 1 + n + self.iavg//2)] + self.XYZslice], axis=0)

    def _animate(self, n_frame):
        """Update all drawables. First the title, then calls self.func."""
        drawables = self.func(*n_frame, self)
        self._update_title(n_frame[0])
        return (*drawables, self.titletext)

    def FuncAnimation(self, interval=33, **kwargs):
        """Return a Matplotlib.animation.FuncAnimation object of this animation."""
        return anim.FuncAnimation(self.fig, self._animate, frames=self._get_frames(), interval=interval, **kwargs)

    def save(self, filename, dpi=250, codec='h264', fps=15, debug=False):
        """Save the animation to file using the homemade PIPE FFMpeg writer."""
        self.fig.set_dpi(dpi)
        w, h = self.fig.canvas.get_width_height()
        command = ['ffmpeg',
                   '-y', '-r', '{}'.format(fps),
                   '-s', '{w:d}x{h:d}'.format(w=w, h=h),
                   '-pix_fmt', 'argb',
                   '-f', 'rawvideo', '-i', '-',
                   '-vcodec', codec, filename
                   ]
        with CommandOutputStreams(command, stdout=str(Path(filename).parent / 'stdout.log'), stderr=str(Path(filename).parent / 'stderr.log')) as (stderr, stdout):
            p = proc.Popen(command, stdin=proc.PIPE, stdout=stdout, stderr=stderr)

            for n, frame in self._get_frames():
                if debug: print('\rAnimation {} Frame: {}'.format(filename, n), end='')
                self._animate((n, frame))

                self.fig.canvas.draw()

                string = self.fig.canvas.tostring_argb()

                p.stdin.write(string)

            # print(p.stderr.read().decode())
            # print(p.stdout.read().decode())
            p.communicate()


class FasterFFMpegWriter(anim.FFMpegWriter):
    def __init__(self, **kwargs):
        """Initialize the Writer object.

        Overrides any value given to -pix_fmt in extra_args to 'argb'
        """
        super().__init__(**kwargs)
        self.frame_format = 'argb'

    def grab_frame(self, **savefig_kwargs):
        '''Grab the image information from the figure and save as a movie frame.

        Doesn't use savefig to be faster. So savefig_kwargs will be ignored.
        '''
        anim.verbose.report('MovieWriter.grab_frame: Grabbing frame.',
                            level='debug')
        try:
            # re-adjust the figure size in case it has been changed by the
            # user.  We must ensure that every frame is the same size or
            # the movie will not save correctly.
            self.fig.set_size_inches(self._w, self._h)
            self.fig.set_dpi(self.dpi)
            self.fig.canvas.draw()
            self._frame_sink().write(self.fig.canvas.tostring_argb())
        except (RuntimeError, IOError) as e:
            out, err = self._proc.communicate()
            anim.verbose.report('MovieWriter -- Error '
                                'running proc:\n%s\n%s' % (out,
                                                           err), level='helpful')
            raise IOError('Error saving animation to file (cause: {0}) '
                          'Stdout: {1} StdError: {2}. It may help to re-run '
                          'with --verbose-debug.'.format(e, out, err))
