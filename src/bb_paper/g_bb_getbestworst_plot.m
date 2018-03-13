function g_bb_getbestworst_plot
ncoords = 20;

[~,shortwhd] = g_imdb_choosedb;

zht = 0:100:500;
snapszht = 0;
userealsnaps = false;
improc = '';
shiftridfs = false;
dosave = true;
joinpdfs = [];
figtype = [];
doautoridf = false;
dointeractive = true;

getbest = inputval('Use best points (cf. worst)?',false);

snapsonly = false;
[meandat,extremedat,routenum,mindist] = g_bb_getbestworst(shortwhd,zht, ...
    snapszht,snapsonly,getbest,ncoords,[],[]);
if getbest
    dat = meandat;
else
    dat = extremedat;
end

if getbest
    fprefix = sprintf('best_d%d',mindist);
else
    fprefix = sprintf('worst_d%d',mindist);
end
g_bb_ridf(shortwhd,routenum,zht,snapszht,userealsnaps,improc, ...
    dat.coords,shiftridfs,dosave,joinpdfs,figtype, ...
    doautoridf,dointeractive,dat.headings,dat.errs,dat.allerrs,fprefix)
