#!/bin/sh
#SBATCH -N 1
#SBATCH -n 48
#SBATCH -p v5_192

source ~/.xufy
module load intel/17.0.5-cjj mpi/intel/17.0.5-cjj

export SLURM_OVERLAP=1


for i in 1.2
do
cd $i
for j in `seq 39 10 99`
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


#for i in 1.2 1.1 1.0 0.9 0.8 0.7 0.6 0.55
for i in 1.1 1.0 0.9
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

srun -n 48 vasp_std >log

rm CHG* IBZKPT CONTCAR DOSCAR EIGENVAL OSZICAR PCDAT POTCAR REPORT WAVECAR XDATCAR

cd ../
done
cd ../
done

