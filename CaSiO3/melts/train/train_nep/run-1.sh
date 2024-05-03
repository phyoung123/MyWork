#!/bin/sh

export CUDA_VISIBLE_DEVICES=1
for i in 5000
do
mkdir $i  
for j in 1.4 1.3 1.2 1.1 1.0 0.9 0.8 0.7 0.6 0.55 0.5
do
mkdir $i/$j
cp model-$j'V0'.xyz ./$i/$j/model.xyz
cd $i/$j

rm dump.xyz thermo.out
cat >run.in <<EOF
potential    ../../../nep.txt
velocity    $i
#dftd3        pbe 12  6
time_step   1

#ensemble    npt_scr $i $i 50 1 50 500
ensemble    nvt_bdp $i $i 100
dump_exyz   100000 0 0
dump_thermo 10000
run         10000000

EOF

gpumd_392

cd ../../
done
done
