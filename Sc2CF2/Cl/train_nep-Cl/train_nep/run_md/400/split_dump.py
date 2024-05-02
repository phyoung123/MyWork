from ase.io import read, write

atoms = read('dump.xyz', index=":")

for i in range(0, len(atoms), 5):
    write('structure-{}.vasp'.format(i), atoms[i])
