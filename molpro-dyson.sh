#!/bin/bash

echo -e "**********************************************************************************************************************"
echo -e "*               This script creates Dyson norm calculation input for trajectories in molpro                          *"
echo -e "*              Please prepare input-part*.inp files beforehand and have all geometries ready                         *"
echo -e "*                                       Author: Pratip Chakraborty                                                   *"
echo -e "**********************************************************************************************************************"

rm -rf DYNAMICS-DYSON-CASSCF-TRAJ

read -p "No of possible trajectories? " TRAJ

mkdir DYNAMICS-DYSON-CASSCF-TRAJ
cd DYNAMICS-DYSON-CASSCF-TRAJ
cp -rf /home/pratip/MOLPRO_DYSON_URACIL_TRPES/DATA-FOR-TRPES-CASSCF/GEOM-TRAJ-TRPES-CASSCF-URA/TRAJ* .

#i = trajectories, j = time-step, neutral = active state, k = cationic state, S0, S1, S2,...=1,2,3,..., D0,D1,D2...=1,2,3,...
for i in `seq 1 $TRAJ`
do
        if [[ -d "TRAJ$i" ]]; then
                cd TRAJ$i
                for j in `ls *.xyz | sed 's/[A-Za-z]*//g' | sed -r 's/.{4}$//'`
                do
                        mkdir $j
                        cd $j
                        mv ../$j.00.xyz .
                        cp ../../../input-part*.inp .
                        neutral=`grep "PES" $j.00.xyz | awk '{print $6}'`
                        grep -A12 "PES" $j.00.xyz | grep -v "PES" > geom.xyz   # "-A12" because this script is for uracil which has 12 atoms. Change accordingly.
                        for k in `seq 1 5`
                        do
                                cat input-part1.inp geom.xyz input-part2.inp geom.xyz input-part3.inp > traj$i-$j-$neutral-$k.inp    # combining input file
				#starting from orbitals at FC and get wavefunction and set scratch directory
				cp /JobRaid500MB/pratip/DYNAMICS-DYSON-URACIL-CASSCF-TRAJ/test-uracil-fc.wfu /JobRaid500MB/pratip/DYNAMICS-DYSON-URACIL-CASSCF-TRAJ/traj$i-$j-$neutral-$k.wfu  
				# replace defaults in the input sample file for calculations on trajectories
                                sed -i "s/sample/traj$i-$j-$neutral-$k/g" traj$i-$j-$neutral-$k.inp
                                sed -i "s/neustate= 1/neustate= $neutral/g" traj$i-$j-$neutral-$k.inp
                                sed -i "s/catstate= 1/catstate= $k/g" traj$i-$j-$neutral-$k.inp
                                sed -i "s/stateb=1.1/stateb=$neutral.1/g" traj$i-$j-$neutral-$k.inp
                                sed -i "s/statek=1.1/statek=$k.1/g" traj$i-$j-$neutral-$k.inp
                        done
                        rm input-part*.inp geom.xyz
                        cd ..
                done
                cd ..
        else
                continue
        fi
done

cd ..

echo -e "Do not forget to randomly check a few files to make sure things are fine..."
