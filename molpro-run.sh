#!/bin/bash

#echo -e "**********************************************************************************************************************"
#echo -e "*                       This script runs Dyson norm calculations for trajectories in molpro                          *"
#echo -e "*                                     Please run "molpro-dyson.sh" beforehand                                        *"
#echo -e "*                                       Author: Pratip Chakraborty                                                   *"
#echo -e "**********************************************************************************************************************"

read -p "No of possible trajectories? " TRAJ
read -p "Maximum simulation window? " Timlim

cd DYNAMICS-DYSON-CASSCF-TRAJ

# i = trajectories, j = time-step, neutral = active state, k = cationic state, indices start at 1,2,3,....
for i in `seq 1 $TRAJ`
do
        if [[ -d "TRAJ$i" ]]; then
                cd TRAJ$i
                for j in `seq 0 10 $timlim`
                do
                        if [[ -d "$j" ]]; then
                                cd $j
                                neutral=`grep "PES" $j.00.xyz | awk '{print $6}'`
                                for k in `seq 1 5`
                                do
                                        nohup molpro -d /JobRaid500MB/pratip/DYNAMICS-DYSON-URACIL-CASSCF-TRAJ/ traj$i-$j-$neutral-$k.inp > traj$i-$j-$neutral-$k.out &
                                done
                                wait
                                cd ..
                        else
                                continue
                        fi
                done
                cd ..
        else
                continue
        fi
done

cd ..


