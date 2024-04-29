#!/bin/sh

source ~/xufy/.deepmd_env.sh
for i in `seq 300 100 700`
do
cp split_dump.py ./$i
cd $i
python split_dump.py

for j in `seq 0 5 95`
do
mkdir $j
cp ../INCAR ./$j
cp ../POTCAR ./$j
mv structure-${j}.vasp ./$j/POSCAR

cd $j
echo $i-$j
mpirun -n 52 vasp_std >log
rm CHG* IBZKPT WAVECAR REPORT OSZICAR CONTCAR DOSCAR EIGENVAL PCDAT POTCAR XDATCAR
cd ../
done
cd ..
done
