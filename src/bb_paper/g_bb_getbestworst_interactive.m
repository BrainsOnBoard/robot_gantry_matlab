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
worstcoords = g_bb_getbestworst(shortwhd,zht,snapszht,snapsonly,getbest,ncoords);

for i = 1:ncoords
    g_bb_ridf(shortwhd,routenum,zht,snapszht,userealsnaps,improc, ...
        worstcoords(i,:),shiftridfs,dosave,joinpdfs,figtype, ...
        doautoridf,dointeractive)
    
    try
        ginput(1);
    catch ex
        if strcmp(ex.identifier,'MATLAB:ginput:FigureDeletionPause')
            break
        end
    end
end
