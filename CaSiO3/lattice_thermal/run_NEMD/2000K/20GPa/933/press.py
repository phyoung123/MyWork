import numpy as np

press = np.loadtxt('thermo.out')
ndata = press.shape[0]
print('data point: ', ndata)
Px = press[50:,3]
Py = press[50:,4]
Pz = press[50:,5]
ave = np.mean([Px, Py, Pz])
print('average press: ', ave)
