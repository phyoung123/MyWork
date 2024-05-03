#!/bin/sh
#PBS -N 22
#PBS -j oe
#PBS -l nodes=node22:ppn=52
#PBS -m e
#PBS -M phyang0106@qq.com


cd $PBS_O_WORKDIR

source /apps/software/intel2017/compilers_and_libraries_2017.4.196/linux/bin/compilervars.sh intel64
source /apps/software/intel2017/compilers_and_libraries_2017.4.196/linux/mpi/intel64/bin/mpivars.sh
source /apps/software/intel2017/compilers_and_libraries_2017.4.196/linux/mkl/bin/mklvars.sh intel64

source ~/xufy/.GPUMD_env.sh
ulimit -s unlimited


for i in 1.1
do
#cp split_dump.py ./$i  

cd $i  
#python split_dump.py 

for j in `seq 79 10 99`
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
