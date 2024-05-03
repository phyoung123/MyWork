#!/bin/sh

#PBS -N 19
#PBS -j oe
#PBS -l nodes=node19:ppn=52

cd $PBS_O_WORKDIR
source /apps/software/intel/compilers_and_libraries_2019.3.199/linux/bin/compilervars.sh intel64
source /apps/software/intel/compilers_and_libraries_2019.3.199/linux/mpi/intel64/bin/mpivars.sh
source /apps/software/intel/compilers_and_libraries_2019.3.199/linux/mkl/bin/mklvars.sh intel64

#source ~/xufy/.GPUMD_env.sh
ulimit -s unlimited


for i in 1.0
do
cd $i
for j in 69 79 89 99
do
#mkdir $j

#mv structure-$j.vasp ./$j/POSCAR

cd $j

cp ../../INCAR_sta ./INCAR
cp ../../POTCAR ./

mpirun -n 52 vasp_std >log

rm CHG* IBZKPT CONTCAR DOSCAR EIGENVAL OSZICAR PCDAT POTCAR REPORT WAVECAR XDATCAR

cd ../
done
cd ../
done

