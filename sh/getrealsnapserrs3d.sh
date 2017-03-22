#!/bin/sh
#$ -j y
#$ -o logs
#$ -q inf.q,eng-inf_himem.q
#$ -S /bin/bash

improc=bin

echo running on queue: $QUEUE

#SGE_TASK_ID=1
params=(`awk "NR==$SGE_TASK_ID" ~/sub_gantry.txt`)
echo params: ${params[*]}

module add matlab

#g_imdb_route_getrealsnapserrs3d(shortwhd{i},'arena2_pile',routenum,cres,czht,useinfomax,forcegen)
matlab -nodisplay -singleCompThread -nojvm -r "g_imdb_route_getrealsnapserrs3d('${params[0]}','${params[1]}',${params[2]},${params[3]},${params[4]},${params[5]},'$improc',false);exit"

