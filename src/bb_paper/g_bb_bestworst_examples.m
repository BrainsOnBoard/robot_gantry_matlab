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

coordnums = 4;
shortwhd = 'imdb_2017-02-09_001';
routenum = 1;

snapsonly = false;
getbest = true;
[meandat,extremedat] = g_bb_getbestworst(shortwhd,zht, ...
    snapszht,snapsonly,getbest,ncoords,routenum);
if getbest
    dat = meandat;
else
    dat = extremedat;
end
dat.errs = dat.errs(coordnums);
dat.allerrs = dat.allerrs(coordnums,:);
dat.headings = dat.headings(coordnums,:);
dat.coords = dat.coords(coordnums,:);

if getbest
    fprefix = 'best_pub_';
else
    fprefix = 'worst_pub_';
end
g_bb_ridf(shortwhd,routenum,zht,snapszht,userealsnaps,improc, ...
    dat.coords,shiftridfs,dosave,joinpdfs,figtype, ...
    doautoridf,dointeractive,dat.headings,dat.errs,dat.allerrs,fprefix, ...
    pubgrade)
