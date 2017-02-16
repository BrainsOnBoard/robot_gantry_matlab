#!/bin/sh

subfn=~/sub_gantry.txt
if [ -f $subfn ]; then
	rm $subfn
fi

imdb=unwrap_imdb3d_2017-02-09_001
arenafn=arena2_pile
routenum=3

njob=0
for infomax in true false; do
	for res in 360 180 90; do
		for zht in {0..500..100}; do
			echo $imdb $arenafn $routenum $res $zht $infomax >> $subfn
			(( njob++ ))
		done
	done
done

echo $njob jobs
module add sge
qsub -t 1-$njob ~/gantry/sh/getrealsnapserrs3d.sh
