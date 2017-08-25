function [imxi,imyi,heads,whsn,err,nearest,dist,snx,sny,snth,errsel,p,isnew,allwhsn,ridfs]=g_imdb_route_getrealsnapserrs3d(shortwhd,arenafn,routenum,res,zht,useinfomax,improc,forcegen,improcforinfomax)
if nargin < 9
    improcforinfomax = false;
end
if nargin < 8
    forcegen = false;
end
if nargin < 7
    improc = 'histeq';
end

getallwhsn = true;
nth = 360;

whd = fullfile(g_dir_imdb,shortwhd);

if useinfomax
    infomaxstr = '_infomax';
else
    infomaxstr = '';
end

if useinfomax && ~improcforinfomax
    improc = '';
end

if isempty(improc)
    improcstr = '';
else
    improcstr = [improc,'_'];
end
figdatfn = fullfile(g_dir_imdb_routes_figdata,sprintf('wrapped_g_imdb_route_geterrs_%s%s_%s_%03d_res%03d_z%d%s.mat',improcstr,shortwhd,matfileremext(arenafn),routenum,res,zht,infomaxstr));
ridfsfigdatfn = fullfile(g_dir_imdb_routes_ridfs_figdata,sprintf('wrapped_g_imdb_route_geterrs_%s%s_%s_%03d_res%03d_z%d%s.mat',improcstr,shortwhd,matfileremext(arenafn),routenum,res,zht,infomaxstr));

fprintf('target file: %s\n',figdatfn);
isnew = ~exist(figdatfn,'file');
getridfs = nargout >= 14;
haveridfs = exist(ridfsfigdatfn,'file');
if ~isnew && ~forcegen && (~getridfs || haveridfs)
    load(figdatfn);
    if getridfs
        load(ridfsfigdatfn);
    end
else
    if forcegen && ~isnew
        warning('generating fig data even though it already exists')
    end
    
    imfun = gantry_getimfun(improc);
    
    weight_update_count = 30;
    
    [snaps,~,snx,sny,snth]=g_imdb_route_getrealsnaps3d(arenafn,routenum,res,improc);
    
    load(fullfile(whd,'im_params.mat'),'p')
    if ~any(zht == p.zs)
        error('invalid height: %f',zht);
    end
    
    zi = find(p.zs==zht);
    
    valids = g_imdb_getimpts(whd,p,zi);
    ind = find(valids);
    nheads = length(ind);
    [imxi,imyi] = ind2sub(size(valids),ind);
    heads = NaN(nheads,1);
    
    newsz = [size(snaps,1),size(snaps,2)];
    startprogbar(10,nheads,'calculating headings',true)
    if useinfomax
        infomax_wts = [];
        for xi = 1:weight_update_count
            infomax_wts = infomax_train(size(snaps,3), reshape(snaps,[prod(newsz), size(snaps,3)]), infomax_wts);
        end
        
        ridfs = NaN(nheads,nth);
        for i = 1:nheads
            im = g_imdb_getprocim(whd,imxi(i),imyi(i),zi,imfun,res);
            [heads(i),~,cridf] = infomax_gethead(im,[],infomax_wts);
            ridfs(i,:) = cridf';
            
            if progbar
                return
            end
        end
        
        whsn = [];
        allwhsn = [];
    else
        allwhsn = NaN([size(heads),size(snaps,3)]);
        
        ridfs = NaN(nheads,nth,size(snaps,3));
        for i = 1:nheads
            im = g_imdb_getprocim(whd,imxi(i),imyi(i),zi,imfun,res);
            [heads(i),~,cwhsn,cridfs] = ridfheadmulti(im,snaps,'wta',[],nth,[],getallwhsn);
            allwhsn(i,:) = cwhsn';
            ridfs(i,:,:) = shiftdim(cridfs,-1);
            
            if progbar
                return
            end
        end
        
        whsn = allwhsn(:,1);
    end
    
    if ~exist(g_dir_imdb_routes_figdata,'dir')
        mkdir(g_dir_imdb_routes_figdata);
    end
    fprintf('Saving to %s...\n',figdatfn);
    save(figdatfn,'imxi','imyi','heads','whsn','snx','sny','snth','p','weight_update_count','zht');

    if ~exist(g_dir_imdb_routes_ridfs_figdata,'dir')
        mkdir(g_dir_imdb_routes_ridfs_figdata);
    end
    fprintf('Saving RIDFs to %s...\n\n',ridfsfigdatfn);
    save(ridfsfigdatfn,'ridfs','allwhsn');
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