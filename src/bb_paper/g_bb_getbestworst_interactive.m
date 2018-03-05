function g_bb_getbestworst_interactive
ncoords = 20;

[~,shortwhd] = g_imdb_choosedb;
routenum = 1;

zht = 0:100:500;
snapszht = 200;
userealsnaps = false;
improc = '';
shiftridfs = false;
dosave = false;
joinpdfs = [];
figtype = [];
doautoridf = false;
dointeractive = true;

% get worst mean coords
getbest = false;
snapsonly = false;
[~,dat] = g_bb_getbestworst(shortwhd,zht,snapszht,snapsonly,getbest,ncoords);

g_bb_ridf(shortwhd,routenum,zht,snapszht,userealsnaps,improc, ...
    dat.coords,shiftridfs,dosave,joinpdfs,figtype, ...
    doautoridf,dointeractive,dat.headings,dat.errs,dat.allerrs)
