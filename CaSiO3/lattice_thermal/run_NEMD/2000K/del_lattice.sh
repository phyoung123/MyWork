#!/bin/sh

for j in 20 60 100 120
do
echo $j 'GPa'
for i in 533 633 733 833 933
do
cd $j'GPa'/size/$i
echo $i 
cat lattice.dat
cd ../../../
done
done

