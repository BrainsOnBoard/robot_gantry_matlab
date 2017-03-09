#!/bin/bash
#$ -S /bin/bash
#$ -j y
#$ -o logs
#$ -q eng-inf_himem.q,eng-inf_parallel.q,inf.q,inf_amd.q

#SGE_TASK_ID=1
jobfile=~/gantry_compimdb_jobfile.txt

echo running on $QUEUE
# gantry_rf_compareimdb_getdata(arenafn,whroute,imdirshort,zi,snwstr,nth,p)
cmd=`awk 'NR=='$SGE_TASK_ID' { printf "gantry_rf_compareimdb_getdata(%s,%d,%s,%d,%s,%d,%d)", ""$1"", $2, ""$3"", $4, ""$5"", $6, $7 }' $jobfile`
echo $cmd

module add matlab
matlab -singleCompThread -nodisplay -nojvm -r "cd ~/gantry;$cmd;exit"
