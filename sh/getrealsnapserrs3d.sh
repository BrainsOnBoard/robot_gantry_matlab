#!/bin/sh
#$ -j y

module add matlab

#imdb_route_getrealsnapserrs3d(shortwhd{i},'arena2_pile',routenum,cres,czht,useinfomax,forcegen)
matlab -nodisplay -nojvm -r "imdb_route_getrealsnapserrs3d('$1','$2',$3,$4,$5,$6,false);"
