import numpy as np

data = np.loadtxt('lattice.dat')
Ly = float(data[1])
Lx = float(data[0])
print('Ly = ', Ly)

from pylab import *
from ase.build import graphene_nanoribbon
from ase.io import write, read
from gpyumd.atoms import GpumdAtoms
from gpyumd.load import load_shc, load_compute
import numpy as np


aw = 2
fs = 16
font = {'size'   : fs}
matplotlib.rc('font', **font)
matplotlib.rc('axes' , linewidth=aw)

def set_fig_properties(ax_list):
    tl = 8
    tw = 2
    tlm = 4

    for ax in ax_list:
        ax.tick_params(which='major', length=tl, width=tw)
        ax.tick_params(which='minor', length=tlm, width=tw)
        ax.tick_params(axis='both', direction='in', right=True, top=True)


compute = load_compute(['temperature'])
T = compute['temperature']
Ein = compute['Ein']
Eout = compute['Eout']
ndata = T.shape[0]
temp_ave = mean(T[int(ndata/2)+1:, 1:], axis=0)

dt = 0.001  # ps
Ns = 1000  # Sample interval
t = dt*np.arange(1,ndata+1) * Ns/1000  # ns

figure(figsize=(10,5))
subplot(1,2,1)
set_fig_properties([gca()])
group_idx = range(1,9)
plot(group_idx, temp_ave,linewidth=3,marker='o',markersize=10)
xlim([1, 8])
gca().set_xticks(group_idx)
#ylim([290, 310])
#gca().set_yticks(range(290,311,5))
xlabel('group index')
ylabel('T (K)')
title('(a)')

subplot(1,2,2)
set_fig_properties([gca()])
plot(t, Ein/1000, 'C3', linewidth=3)
plot(t, Eout/1000, 'C0', linewidth=3, linestyle='--' )
#xlim([0, 1])
#gca().set_xticks(linspace(0,1,6))
#ylim([-10, 10])
#gca().set_yticks(range(-10,11,5))
xlabel('t (ns)')
ylabel('Heat (keV)')
title('(b)')
tight_layout()
savefig('Q.jpg', dpi=600)

deltaT = temp_ave[0] - temp_ave[-1]  # [K]
print(deltaT)

Q1 = (Ein[int(ndata/2)] - Ein[-1])/(ndata/2)/dt/Ns
Q2 = (Eout[-1] - Eout[int(ndata/2)])/(ndata/2)/dt/Ns
Q = mean([Q1, Q2])  # [eV/ps]
print('Q1 = ', Q1)
print('Q2 = ', Q2)
print('Q = ', Q)

#l = gnr.cell.lengths()
l = Ly
A = l*l/100  # [nm2]
G1 = 160*Q/deltaT/A  # [GW/m2/K]
print('G1: ',G1)


Q1 = (Ein[int(ndata/5)] - Ein[int(2*ndata/5)])/(ndata/5)/dt/Ns
Q2 = (Eout[-1] - Eout[int(4*ndata/5)])/(ndata/5)/dt/Ns
Q = mean([Q1, Q2])  # [eV/ps]
print('Q1 = ', Q1)
print('Q2 = ', Q2)
print('Q = ', Q)

#l = gnr.cell.lengths()
#l = 32.471676
A = l*l/100  # [nm2]
G2 = 160*Q/deltaT/A  # [GW/m2/K]
print('G2: ',G2)

Q1 = (Ein[int(2*ndata/5)] - Ein[int(3*ndata/5)])/(ndata/5)/dt/Ns
Q2 = (Eout[int(4*ndata/5)] - Eout[int(3*ndata/5)])/(ndata/5)/dt/Ns
Q = mean([Q1, Q2])  # [eV/ps]
print('Q1 = ', Q1)
print('Q2 = ', Q2)
print('Q = ', Q)

#l = gnr.cell.lengths()
#l = 32.471676
A = l*l/100  # [nm2]
G3 = 160*Q/deltaT/A  # [GW/m2/K]
print('G3: ',G3)

Q1 = (Ein[int(3*ndata/5)] - Ein[int(4*ndata/5)])/(ndata/5)/dt/Ns
Q2 = (Eout[int(3*ndata/5)] - Eout[int(2*ndata/5)])/(ndata/5)/dt/Ns
Q = mean([Q1, Q2])  # [eV/ps]
print('Q1 = ', Q1)
print('Q2 = ', Q2)
print('Q = ', Q)

#l = gnr.cell.lengths()
#l = 32.471676
A = l*l/100  # [nm2]
G4 = 160*Q/deltaT/A  # [GW/m2/K]
print('G4: ',G4)

Q1 = (Ein[int(4*ndata/5)] - Ein[-1])/(ndata/5)/dt/Ns
Q2 = (Eout[int(2*ndata/5)] - Eout[int(1*ndata/5)])/(ndata/5)/dt/Ns
Q = mean([Q1, Q2])  # [eV/ps]
print('Q1 = ', Q1)
print('Q2 = ', Q2)
print('Q = ', Q)

#l = gnr.cell.lengths()
#l = 32.471676
A = l*l/100  # [nm2]
G5 = 160*Q/deltaT/A  # [GW/m2/K]
print('G5: ',G5)

mean_Q = np.mean([G1, G2, G3, G4, G5])
mean_Q_error = np.std([G1, G2, G3, G4, G5])
print('total mean: ', np.mean([G1, G2, G3, G4, G5]), 'stand error: ', np.std([G1, G2, G3, G4, G5]))

# with open('../../../Q.dat', 'a') as fo:
#     fo.write("supercell  Lx    mean_Q     mean_Q_error\n")
with open('../../../Q.dat', 'a') as fo:
    fo.write("{}  {}  {}  {}\n".format(933, Lx, mean_Q, mean_Q_error))
