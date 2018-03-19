clear

zht = 0:100:500;
snapszht = 0;
userealsnaps = false;
improc = '';
shiftridfs = false;
dosave = true;
joinpdfs = [];
doautoridf = false;
dointeractive = true;
ncoords = 20;
ridfx360 = true;
skipexisting = true;
res = 90;
pubgrade = true;
if pubgrade
    figtype = 'svg';
else
    figtype = 'pdf';
end

shortwhd = {
    'imdb_2017-02-09_001'; % pile
    'imdb_2017-06-06_001'  % plants
    };
coords = {[
    1300 1500; % 14. selecting snaps further from pile with height
    600 500   % d16. good perf with distant snap
    ], [
    600 800; % d1. good example
    300 1500  % d3. low err with far-away snap
    ]};
routenum = [1 1];

for i = 1:length(shortwhd)
    [dat.headings,dat.allerrs,dat.whsn] = g_bb_getdatapartial( ...
        coords{i},shortwhd{i},routenum(1),res,zht,false,improc,false, ...
        [],false,snapszht,dosave);
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
    g_bb_ridf(shortwhd{i},routenum(1),zht,snapszht,userealsnaps,improc, ...
        coords{i},shiftridfs,dosave,joinpdfs,figtype, ...
        doautoridf,dointeractive,dat.headings,dat.errs,dat.allerrs,fprefix, ...
        pubgrade,ridfx360,skipexisting)
end
