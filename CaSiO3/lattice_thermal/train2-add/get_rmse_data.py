import numpy as np

energy = np.loadtxt('energy_train.out')
rmse_energy = np.sqrt(np.mean((energy[:,0] - energy[:,1])**2))
print(rmse_energy*1000, 'meV/atom')

force = np.loadtxt('force_train.out')
rmse_force = np.sqrt(np.mean((force[:, 3:6]-force[:, 0:3])**2))
print(rmse_force*1000, 'meV/A')

#virial_nep = np.loadtxt('virial-nep-test-GPa.dat')
#virial_vasp = np.loadtxt('virial-vasp-test-GPa.dat')
#rmse_virial = np.sqrt(np.mean((virial_nep[:, :]-virial_vasp[:,:])**2))
#print(rmse_virial, 'GPa')
