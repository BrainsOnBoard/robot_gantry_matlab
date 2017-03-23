function g_live_train_capturesnaps(arenafn,routenum)
%G_LIVE_TRAIN_CAPTURESNAPS   Use the gantry to get snapshots for specified
%route.
%
%   G_LIVE_TRAIN_CAPTURESNAPS('arena1.mat',1) gets the snapshots for route
%   1, with objects in arena as specified in arena1.mat

cd(fullfile(mfiledir,'../..'));

ptr.zht = 200; % mm

g = g_control_object;

for curroute=routenum
    datafn = sprintf('route_%s_%03d',arenafn,curroute);
    dataffn = fullfile(g_dir_routes,datafn);
    load(dataffn,'p','clx','cly','cli','whclick','rclx','rcly')
    
    if isempty(arenafn)
        minht = ptr.zht;
    else
        load(arenafn,'objhts')
        minht = max(objhts);
    end
    g.move([0;0;minht]);
    
    load('gantry_centrad','unwrapparams')
    snapdir = fullfile(g_dir_routes_snapshots,['snaps_' datafn]);
    if exist(snapdir,'dir')
        error('snap dir already exists')
    end
    mkdir(snapdir)
    
    clx = round(clx*1000/p.arenascale);
    cly = round(cly*1000/p.arenascale);
    g.move([clx(1);cly(1);minht]);
    startprogbar(1,length(clx),[],true);
    for i = 1:length(clx)
        g.move([clx(i);cly(i);ptr.zht])
        fr = g.get_frame;
        save(fullfile(snapdir,sprintf('%05d_%s.mat',i,datafn)),'fr')
        if progbar
            delete(g)
            return
        end
    end
    
    save(dataffn,'-append','ptr')
    
    g.move([clx(i);cly(i);minht])    
end

delete(g)

disp('Unwrapping images...')
for curroute=routenum
    g_live_train_unwrapsnaps(arenafn,curroute)
end