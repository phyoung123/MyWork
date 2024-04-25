#!/bin/sh

for j in 20 60 100 120
do
echo $j 'GPa'
for i in 533 633 733 833 933
do
cp press.py $j'GPa'/size/$i/
cd $j'GPa'/size/$i
echo $i

cat >press.py <<EOF
import numpy as np

press = np.loadtxt('thermo.out')
ndata = press.shape[0]
print('data point: ', ndata)
Px = press[50:,3]
Py = press[50:,4]
Pz = press[50:,5]
ave = np.mean([Px, Py, Pz])
print('average press: ', ave)
EOF

python press.py
cd ../../../
done
done
