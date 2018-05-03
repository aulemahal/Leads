"""
Fonctions pour calculer et analyser des spectres
"""
import numpy as np


def get_spectrum(U, V, W, nbins):
    FKE = np.zeros([U.shape[0], U.shape[1], U.shape[2]//2 + 1])
    for ui in (U, V, W):
        FKE += np.abs(np.fft.rfftn(ui))**2

    K, L, M = np.meshgrid(np.fft.fftfreq(U.shape[0]) * U.shape[0], np.fft.fftfreq(U.shape[1]) * U.shape[1], np.fft.rfftfreq(U.shape[2]) * U.shape[2], indexing='ij')
    dists = K**2 + L**2 + M**2

    return np.histogram(dists.ravel(), bins=nbins, weights=FKE.ravel())


if __name__ == '__main__':
    import matplotlib.pyplot as plt

    print('Test de get_spectrum avec une matrice aléatoire.')
    spec, bins = get_spectrum(np.random.randn(120, 120, 120), np.random.randn(120, 120, 120), np.random.randn(120, 120, 120), 20)
    print(spec, bins)
    plt.plot((bins[:-1] + bins[1:])/2, spec)
    plt.show()
