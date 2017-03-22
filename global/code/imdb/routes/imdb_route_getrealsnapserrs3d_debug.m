function [imxi,imyi,heads,whsn,err,nearest,dist,snx,sny,snth,errsel,p,fileexists,allwhsn,ridfs]=imdb_route_getrealsnapserrs3d_debug(shortwhd,arenafn,routenum,res,zht,useinfomax,forcegen)
if nargin < 5
    forcegen = false;
end

getallwhsn = true;

cd(fullfile(mfiledir,'..','..','..'))

trainheight = 200;

whd = fullfile(g_dir_imdb,shortwhd);

if useinfomax
    infomaxstr = '_infomax';
else
    infomaxstr = '';
end
figdatfn = fullfile(g_dir_imdb_routes_figdata,sprintf('wrapped_imdb_route_geterrs_%s_%s_%03d_res%03d_z%d%s.mat',shortwhd,matfileremext(arenafn),routenum,res,zht,infomaxstr));

fprintf('target file: %s\n',figdatfn);
fileexists = varsinmatfile(figdatfn,'ridfs');
if fileexists && ~forcegen
    load(figdatfn);
else
    if forcegen && fileexists
        warning('generating fig data even though it already exists')
    end
    
    weight_update_count = 30;
    
    %     function [snaps,whclick,clx,cly,clth,p,ptr]=imdb_route_getrealsnaps3d(arenafn,routenum)
    [snaps,clickis,snx,sny,snth]=imdb_route_getrealsnaps3d(arenafn,routenum,res);
    load(fullfile(whd,'im_params.mat'),'p')
    crop = load('gantry_cropparams.mat');
    zi = find(p.zs==zht);
    
    heads = NaN(length(p.ys),length(p.xs));
    
    newsz = [size(snaps,1),size(snaps,2)];
    startprogbar(10,numel(heads),'calculating headings',true)
    if useinfomax
        infomax_wts = [];
        for xi = 1:weight_update_count
            infomax_wts = infomax_train(size(snaps,3), reshape(snaps,[prod(newsz), size(snaps,3)]), infomax_wts);
        end
        
        for xi = 1:length(p.xs)
            for yi = 1:length(p.ys)
                fr = loadim(xi,yi,zi);
                if ~isempty(fr)
                    heads(yi,xi) = infomax_gethead(fr,[],infomax_wts);
                    
                    %                     if(isnan(heads(xi,yi)))
                    %                         keyboard
                    %                     end
                end
                
                if progbar
                    return
                end
            end
        end
        
        whsn = [];
        allwhsn = [];
    else
        allwhsn = NaN([size(heads),size(snaps,3)]);
        
        % select only the points on the route which were clicked on
        %         snaps = snaps(:,:,clickis);
        %         snx = snx(clickis);
        %         sny = sny(clickis);
        %         snth = atan2(diff(sny),diff(snx));
        %         snth(end+1) = snth(end);
        
        ridfs = NaN(length(p.ys),length(p.xs),360,size(snaps,3));
        for yi = 1:length(p.ys)
            for xi = 1:length(p.xs)
                fr = loadim(xi,yi,zi);
                if ~isempty(fr)
                    % function [head,minval,whsn,diffs] = ridfheadmulti(im,imref,snapweighting,angleunit,nth,snths,getallwhsn)
                    [heads(yi,xi),~,cwhsn,cridfs] = ridfheadmulti(fr,snaps,'wta',[],360,[],getallwhsn);
                    allwhsn(yi,xi,:) = shiftdim(cwhsn,-2);
                    ridfs(yi,xi,:,:) = shiftdim(cridfs,-2);
                end
                
                if progbar
                    return
                end
            end
        end
    end
    
    valids = ~isnan(heads);
    heads = heads(valids);
    if ~isempty(allwhsn)
        newallwhsn = NaN(sum(valids(:)),size(allwhsn,3));
        for i = 1:size(allwhsn,3)
            callwhsn = allwhsn(:,:,i);
            newallwhsn(:,i) = callwhsn(valids);
        end
        allwhsn = newallwhsn;
        whsn = allwhsn(:,1);
    end
    
    [imyi,imxi] = ind2sub(size(valids),find(valids));
    
    if ~exist(g_dir_imdb_routes_figdata,'dir')
        mkdir(g_dir_imdb_routes_figdata);
    end
    save(figdatfn,'imxi','imyi','heads','allwhsn','whsn','snx','sny','snth','p','ridfs','weight_update_count','zht');
end

snxi = 1+snx(:) * 1000/(p.imsep*20);
snyi = 1+sny(:) * 1000/(p.imsep*20);

dx = bsxfun(@minus,imxi(:)',snxi);
dy = bsxfun(@minus,imyi(:)',snyi);
alldist = p.imsep * hypot(dy, dx);
[dist,nearest] = min(alldist);

% calculate error on heading (0 to 90 deg)
snth = snth(:);
target_heads = snth(nearest);
err = circ_dist(heads, target_heads);
err = abs(err);
err = min(pi/2,err) * 180/pi;

err_corridor = 2;

mindist = min(hypot(dx,dy));
errsel = mindist <= err_corridor;

    function loadedim=loadim(x,y,z)
        loadedim = g_imdb_getim(whd,x,y,z);
        if ~isempty(loadedim)
            loadedim = imresize(loadedim,newsz,'bilinear');
        end
    end
end
