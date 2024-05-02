#!/bin/sh

#PBS -N 18-cl
#PBS -j oe
#PBS -l nodes=node18:ppn=52
#PBS -m e


cd $PBS_O_WORKDIR

source /apps/software/intel2017/compilers_and_libraries_2017.4.196/linux/bin/compilervars.sh intel64
source /apps/software/intel2017/compilers_and_libraries_2017.4.196/linux/mpi/intel64/bin/mpivars.sh
source /apps/software/intel2017/compilers_and_libraries_2017.4.196/linux/mkl/bin/mklvars.sh intel64


source ~/xufy/.deepmd_env.sh
for i in 400
do
#cp split_dump.py ./$i
cd $i
#python split_dump.py

for j in `seq 45 5 95`
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
