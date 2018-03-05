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
dat = g_bb_getbestworst(shortwhd,zht,snapszht,snapsonly,getbest,ncoords);

for i = 1:ncoords
    inttitle = sprintf('(%d,%d) err: %.2fdeg',dat.coords(i,1), ...
        dat.coords(i,2),dat.errs(i));
    g_bb_ridf(shortwhd,routenum,zht,snapszht,userealsnaps,improc, ...
        dat.coords(i,:),shiftridfs,dosave,joinpdfs,figtype, ...
        doautoridf,dointeractive,inttitle)
    
    try
        ginput(1);
    catch ex
        if strcmp(ex.identifier,'MATLAB:ginput:FigureDeletionPause')
            break
        end
    end
end
