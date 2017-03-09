#!/bin/bash

#arenafn=
#imdb=unwrap_imdb3d_2016-03-29_001
nth=360

jobfile=~/gantry_compimdb_jobfile.txt
if [ -f $jobfile ]
then
    rm $jobfile
fi

nsub=0

for arenafn in '' arena1_boxes
do

for whroute in {1..4}
do

rfn=`printf ~/gantry/routedat/route_%s_%03d.mat "$arenafn" $whroute`
if [ ! -f "$rfn" ]; then
	echo route $rfn does not exist
	continue
fi

for imdb in unwrap_imdb3d_2016-03-23_001 unwrap_imdb3d_2016-03-29_001
do

for fov in 360 180 90 270
do

for snapweighting in infomax #wta '[1,0.75,0.25]' "norm5"
do

for zi in {1..6}
do

outfn=`printf ~/gantry/routedat/route_%s_%03d_%s/diffs_z%03d_wt_%s_fov%03d.mat "$arenafn" $whroute $imdb $zi $snapweighting $fov`
if [ ! -f "$outfn" ]; then
	echo \'$arenafn\' $whroute \'$imdb\' $zi \'$snapweighting\' $nth $fov | tee --append $jobfile
	(( nsub++ ))
#else
#	echo $outfn exists!
fi

done
done
done
done
done
done

module add sge
qsub -t 1-$nsub ~/gantry/gantry_rf_compareimdb.sh
echo $nsub jobs submitted.
