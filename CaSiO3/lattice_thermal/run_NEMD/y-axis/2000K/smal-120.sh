#!/bin/sh

source ~/.GPUMD_env.sh

for i in 100
do
mkdir $i'GPa'
mkdir $i'GPa'/size
#for j in 353 363 373 383 393
for j in 383 393
do 
mkdir $i'GPa'/size/$j
cp model-${i}GPa-$j.xyz ./$i'GPa'/size/$j/model.xyz
cd $i'GPa'/size/$j

cat >run.in <<EOF
potential    /data/home/scv8987/run/xufy/CaSiO3/lattice_thermal/total_data_set/train_2nd/train_add/nep.txt
velocity     2000

ensemble     nvt_ber 2000 2000 100
fix          0
time_step    1
dump_thermo  1000
run          100000

ensemble     heat_lan 2000 100 200 1 8
fix          0
dump_thermo  100000
compute      0 10 100 temperature
run          3000000
EOF

#cat >run-$j.sh <<EOF
##!/bin/sh

#source ~/.GPUMD_env.sh
##nep
#gpumd

#EOF

gpumd3_9
#sbatch --gpus=1 run-$j.sh
cd ../../../
done
done
