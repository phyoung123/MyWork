#!/bin/sh

source ~/xufy/.GPUMD_env.sh
ulimit -s unlimited


for i in 1.0 0.9 0.8
do
cp split_dump.py ./$i  

cd $i  
python split_dump.py 

for j in `seq 9 10 99`
do 

mkdir $j

mv structure-$j.vasp ./$j/POSCAR

cd $j

cp ../../INCAR_sta ./INCAR
cp ../../POTCAR ./ 

mpirun -n 52 vasp_std >log

rm CHG* IBZKPT CONTCAR DOSCAR EIGENVAL OSZICAR PCDAT POTCAR REPORT WAVECAR XDATCAR

cd ../
done
cd ../
done