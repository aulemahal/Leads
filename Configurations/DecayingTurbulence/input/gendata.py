# Generate Data (version python)
import numpy as np
from scipy.signal import tukey
import matplotlib.pyplot as plt


def writeIEEEbin(filename, arr):
    """Write a numpy array to a IEEE (Big-Endian) binary file."""
    if arr.ndim == 2:
        arr = arr.T
    else:
        arr = arr.swapaxes(0, 2)
    arr.astype('>f8').tofile(filename)
    print('Écriture de {}'.format(filename))

N = [120, 120, 120]

# Vitesses initiales randoms
# Mais énergie contrainte entre kmin et kmax + 0 en haut et en bas
kmin = 3
kmax = 5

Fu = np.zeros((N[0], N[1], N[2]//2 + 1), dtype=np.complex)
Fv = np.zeros((N[0], N[1], N[2]//2 + 1), dtype=np.complex)
for k in range(-kmax, kmax + 1):
    for l in range(-kmax, kmax + 1):
        for m in range(kmax + 1):
            if kmin <= np.sqrt(k**2 + l**2 + m**2) <= kmax:
                Fu[k, l, m] = np.random.rand()*np.exp(1j*2*np.random.rand()*np.pi)
                Fv[k, l, m] = np.random.rand()*np.exp(1j*2*np.random.rand()*np.pi)
U = np.fft.irfftn(Fu) * tukey(120)[np.newaxis, np.newaxis, :]
V = np.fft.irfftn(Fv) * tukey(120)[np.newaxis, np.newaxis, :]
U = 0.01*U/np.mean(np.abs(U))
V = 0.01*V/np.mean(np.abs(V))

writeIEEEbin('Uinit.bin', U)
writeIEEEbin('Vinit.bin', V)

# fig of init
print('Génération d\'une figure de U et V initiaux')
fig, axs = plt.subplots(2, 3)
baseslic = [slice(None)]*3
for axrow, (strv, v) in zip(axs, [('U', U), ('V', V)]):
    mx = v.max()
    for dim, (ax, lbls) in enumerate(zip(axrow, ('yz', 'xz', 'xy'))):
        slic = baseslic.copy()
        slic[dim] = 0
        im = ax.imshow(v[slic], vmin=-mx, vmax=mx)
        ax.set_xlabel(lbls[1])
        ax.set_ylabel(lbls[0])
        ax.set_title(strv + ' face 0 en {}'.format('xyz'[dim]))
plt.tight_layout()
fig.savefig('UVinit.png')
print('U : min {:.4f}, max {:.4f}, mean {:.4f}, mean(abs) {:.4f} [cm/s]'.format(U.min(), U.max(), U.mean(), np.abs(U).mean()))
print('V : min {:.4f}, max {:.4f}, mean {:.4f}, mean(abs) {:.4f} [cm/s]'.format(V.min(), V.max(), V.mean(), np.abs(V).mean()))


# Surface heat flux : refine the grid (by 3 x 3) to assign mean heat flux
Qval = 200
Q1 = 0.0001

Qc = Qval + Q1 * (0.5 + np.random.rand(*N[:2]))
writeIEEEbin('Q0', Qc)

print('La version python de gendata n\'écrit pas Tini.')
