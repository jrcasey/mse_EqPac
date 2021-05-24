#!/bin/bash
START=1
END=20700
STEP=300
SLEEP=1000 # 10 minutes


for i in $(seq $START $STEP $END) ; do	
    JSTART=$i
    JEND=$[ $JSTART + $STEP -1 ] 
    echo "Submitting from ${JSTART} to ${JEND}"
    sbatch --array=${JSTART}-${JEND} -p sched_mit_darwin2 --time=12:00:00 job2.sh
	sleep $SLEEP
done
