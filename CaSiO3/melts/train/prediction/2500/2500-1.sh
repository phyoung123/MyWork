#!/bin/sh
#SBATCH -N 1
#SBATCH -n 48
#SBATCH -p v5_192

source /public1/soft/modules/module.sh
module load intel/17.0.5-cjj mpi/intel/17.0.5-cjj
# source ~/.xufy
module load anaconda/3-Python-3.8.3-phonopy-phono3py
source activate xufy

for i in 0.55
do
cd $i
for j in 79 89 99
do
mkdir $j

mv structure-$j.vasp ./$j/POSCAR

cd $j

cp ../../INCAR_sta ./INCAR
cp ../../POTCAR ./

srun -n 48 vasp_std >log

rm CHG* IBZKPT CONTCAR DOSCAR EIGENVAL OSZICAR PCDAT POTCAR REPORT WAVECAR XDATCAR

cd ../
done
cd ../
done
