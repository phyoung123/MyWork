from ase.io import read, write

atoms = read('dump.xyz', index=":")

for i in range(9, 100, 10):
	write('structure-{}.vasp'.format(i), atoms[i], direct=True)

