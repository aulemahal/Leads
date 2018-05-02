# Generate Data (version python)
import numpy as np


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
kmin = 3
kmax = 5

Fu = np.zeros((N[0], N[1], N[2]/2), dtype=np.complex)
Fv = np.zeros((N[0], N[1], N[2]/2), dtype=np.complex)
for k in range(-kmax, kmax + 1):
    for l in range(-kmax, kmax + 1):
        for m in range(kmax + 1):
            if kmin <= np.sqrt(k**2 + l**2 + m**2) <= kmax:
                Fu[k, l, m] = np.random.rand()*np.exp(1j*2*np.random.rand()*np.pi)
                Fv[k, l, m] = np.random.rand()*np.exp(1j*2*np.random.rand()*np.pi)
U = np.fft.irfftn(Fu)
V = np.fft.irfftn(Fv)

writeIEEEbin('Uinit.bin', U)
writeIEEEbin('Vinit.bin', V)


# Surface heat flux : refine the grid (by 3 x 3) to assign mean heat flux
Qval = 200
Q1 = 0.0001

Qc = Qval + Q1 * (0.5 + np.random.rand(N[:2]))
writeIEEEbin('Q0', Qc)

print('La version python de gendata n\'écrit pas Tini.')
