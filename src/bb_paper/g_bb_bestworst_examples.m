function g_bb_bestworst_examples

zht = 0:100:500;
snapszht = 0;
userealsnaps = false;
improc = '';
shiftridfs = false;
dosave = true;
joinpdfs = [];
doautoridf = false;
dointeractive = true;
ridfx360 = true;
res = 90;

pubgrade = true;
skipexisting = true;

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
    2700 1000; % gd14. selecting snaps further from pile with height
    600  500   % gd16. good perf with distant snap
    1400 0;    % b1. selecting snap from opposite side
    0    400   % b13. @550, at end of route, selecting snap from start
    ], [
    600  800; % gd1. good example
    300  1500 % gd3. low err with far-away snap
    ]};
getbest = {
    [true(2,1);false(2,1)];
    true(2,1)};
routenum = [1 1];

for i = 1:length(shortwhd)
    [dat.headings,dat.allerrs,dat.whsn] = g_bb_getdatapartial( ...
        coords{i},shortwhd{i},routenum(1),res,zht,false,improc,false, ...
        [],false,snapszht,dosave);
    dat.errs = mean(dat.allerrs);
    dat.headings = dat.headings';
    dat.allerrs = dat.allerrs';
    dat.whsn = dat.whsn';

    bests = getbest{i};
    if any(bests)
        disp('doing best-matching')
        
        fprefix = 'best_pub_';
        g_bb_ridf(shortwhd{i},routenum(1),zht,snapszht,userealsnaps, ...
            improc,coords{i}(bests,:),shiftridfs,dosave,joinpdfs,figtype, ...
            doautoridf,dointeractive,dat.headings,dat.errs,dat.allerrs, ...
            fprefix,pubgrade,ridfx360,skipexisting)
    end
    
    worsts = ~bests;
    if any(worsts)
        disp('doing worst-matching')
        
        fprefix = 'worst_pub_';
        g_bb_ridf(shortwhd{i},routenum(1),zht,snapszht,userealsnaps, ...
            improc,coords{i}(worsts,:),shiftridfs,dosave,joinpdfs,figtype, ...
            doautoridf,dointeractive,dat.headings,dat.errs,dat.allerrs, ...
            fprefix,pubgrade,ridfx360,skipexisting)
    end
end
