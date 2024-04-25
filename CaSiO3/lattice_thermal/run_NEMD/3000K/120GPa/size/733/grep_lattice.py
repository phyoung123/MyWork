import numpy as np

data = np.genfromtxt("thermo.out", dtype=float)
if data.size > 0:
    last_row = data[-1]
    last_three_values = last_row[-3:]

    with open('lattice.dat', 'w') as fo:
        fo.write("{}  {}  {}\n".format(*last_three_values))
else:
    print("文件为空")

