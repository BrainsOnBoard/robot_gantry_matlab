function [imxi,imyi,heads,whsn,err,nearest,dist,snx,sny,snth,errsel,p,pxsnx,pxsny,pxsnth]=g_imdb_route_geterrs(shortwhd,routenum,res,useinfomax,forcegen)
if nargin < 5
    forcegen = false;
end

whd = fullfile(g_dir_imdb,shortwhd);

if useinfomax
    infomaxstr = '_infomax';
else
    infomaxstr = '';
end
figdatfn = fullfile(g_dir_imdb_routes_figdata,sprintf('g_imdb_route_geterrs_%s_%03d_res%03d%s.mat',shortwhd,routenum,res,infomaxstr));

if exist(figdatfn,'file') && ~forcegen
    load(figdatfn);
else
    if forcegen
        warning('generating fig data even if it already exists')
    end
    
    weight_update_count = 30;
    
    [snaps,clickis,snx,sny,snth,pxsnx,pxsny,pxsnth,crop,p]=g_imdb_route_getsnaps(shortwhd,routenum,res);
    
    heads = NaN(length(p.ys),length(p.xs));
    
    newsz = [size(snaps,1),size(snaps,2)];
    startprogbar(10,numel(heads),'calculating headings',true)
    if useinfomax        
        infomax_wts = [];
        for i = 1:weight_update_count
            infomax_wts = infomax_train(size(snaps,3), reshape(snaps,[prod(newsz), size(snaps,3)]), infomax_wts);
        end

        for i = 1:length(p.ys)
            for j = 1:length(p.xs)
                fr = loadim(j,i);
                if ~isempty(fr)
                    heads(i,j) = infomax_gethead(fr,[],infomax_wts);
                end
                
                if progbar
                    return
                end
            end
        end
        
        whsn = [];
    else
        whsn = NaN(size(heads));
        
        % select only the points on the route which were clicked on
        snaps = snaps(:,:,clickis);
%         snx = snx(clickis);
%         sny = sny(clickis);
%         snth = atan2(diff(sny),diff(snx));
%         snth(end+1) = snth(end);
        
        for yi = 1:length(p.ys)
            for xi = 1:length(p.xs)
                fr = loadim(xi,yi,zi);
                if ~isempty(fr)
                    [heads(yi,xi),~,whsn(yi,xi)] = ridfheadmulti(fr,snaps,'wta',[],360);
                end
                
                if progbar
                    return
                end
            end
        end
    end
    
    valids = ~isnan(heads);
    heads = heads(valids);
    if ~isempty(whsn)
        whsn = whsn(valids);
    end
    
    [imyi,imxi] = ind2sub(size(valids),find(valids));
    
    dx = bsxfun(@minus,imxi(:)',snx(:));
    dy = bsxfun(@minus,imyi(:)',sny(:));
    alldist = p.imsep * hypot(dy, dx);
    [dist,nearest] = min(alldist);
    
    % calculate error on heading (0 to 90 deg)
    snth = snth(:);
    err = circ_dist(heads, snth(nearest));
    err = abs(err);
    err = min(pi/2,err) * 180/pi;
    
    err_corridor = 2;
    interpsep = 0.1;
    
    dx = diff(snx);
    dy = diff(sny);
    snh = hypot(dx,dy);

%     rx = [];
%     ry = [];
%     for j = 1:length(snh)-1
%         ch = 0:interpsep:snh(j);
% 
%         cx = snx(j) + ch * cos(snth(j));
%         cy = sny(j) + ch * sin(snth(j));
% 
%         rx = [rx; cx(:)];
%         ry = [ry; cy(:)];
%     end

    mindist = min(hypot(bsxfun(@minus, imxi(:)', pxsnx), bsxfun(@minus, imyi(:)', pxsny)));
    errsel = mindist <= err_corridor;
    
    if ~exist(g_dir_imdb_routes_figdata,'dir')
        mkdir(g_dir_imdb_routes_figdata);
    end
    save(figdatfn,'imxi','imyi','heads','whsn','err','nearest','dist','snx','sny','snth','pxsnx','pxsny','pxsnth','err_corridor','errsel','p','weight_update_count');
end

    function loadedim=loadim(x,y)
        loadedim = imdb_getim(whd,y,x,crop);
        if ~isempty(loadedim)
            loadedim = imresize(loadedim,newsz,'bilinear');
        end
    end
end