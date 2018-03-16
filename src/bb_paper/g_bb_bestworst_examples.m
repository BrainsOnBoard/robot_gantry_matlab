clear

zht = 0:100:500;
snapszht = 0;
userealsnaps = false;
improc = '';
shiftridfs = false;
dosave = true;
joinpdfs = [];
figtype = 'svg';
doautoridf = false;
dointeractive = true;
ncoords = 20;
pubgrade = true;
ridfx360 = true;
skipexisting = true;

coords = [1900 200; 2700 800];
shortwhd = 'imdb_2017-02-09_001'; % pile
routenum = 1;

[dat.headings,dat.allerrs,dat.whsn] = g_bb_getdatapartial(coords,shortwhd, ...
    routenum,90,zht,false,improc,false,[],false,snapszht,dosave);
dat.coords = coords;
dat.errs = mean(dat.allerrs);
dat.headings = dat.headings';
dat.allerrs = dat.allerrs';
dat.whsn = dat.whsn';

getbest = true;

if getbest
    fprefix = 'best_pub_';
else
    fprefix = 'worst_pub_';
end
g_bb_ridf(shortwhd,routenum,zht,snapszht,userealsnaps,improc, ...
    dat.coords,shiftridfs,dosave,joinpdfs,figtype, ...
    doautoridf,dointeractive,dat.headings,dat.errs,dat.allerrs,fprefix, ...
    pubgrade,ridfx360,skipexisting)
