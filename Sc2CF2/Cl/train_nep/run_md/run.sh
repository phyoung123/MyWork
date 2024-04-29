#!/bin/sh

export CUDA_VISIBLE_DEVICES=1

for i in `seq 300 100 700`
do
mkdir $i

cp model.xyz ./$i/
cd $i
cat >run.in <<EOF
potential           ../../nep.txt
velocity              $i
ensemble              nvt_nhc $i $i 100
time_step             1
dump_thermo           5000
dump_exyz             50000
run                   5000000
EOF

gpumd_392

cd ../

done
