import matplotlib.pyplot as plt
import netCDF4 as nc
# import numpy as np

# Utilise les sorties en netCDF collées
# Fait un plot avec U et W au début et à la fin
dyn = nc.Dataset('dynDiag.nc')

fig, axs = plt.subplots(2, 2, sharex=True, sharey=True)
for axrow, (strv, v) in zip(axs, [('U', dyn.variables['UVEL']), ('W', dyn.variables['WVEL'])]):
    for dim, (ax, time) in enumerate(zip(axrow, (0, -1))):
        mx = v[time, :, 60, :].max()
        im = ax.imshow(v[time, :, 60, :], vmin=-mx, vmax=mx, cmap=plt.cm.RdBu)
        fig.colorbar(im, ax=ax)
        ax.set_xlabel('x')
        ax.set_ylabel('z')
        ax.set_title(strv + [' au début (t = {})'.format(dyn.variables['T'][0]), ' à la fin (t = {})'.format(dyn.variables['T'][-1])][time])
plt.tight_layout()
for axr in axs:
    for ax in axr:
        ax.set_xlim(0, 120)
        ax.set_ylim(0, 120)
plt.show()
