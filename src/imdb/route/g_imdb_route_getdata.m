function [imxi,imyi,heads,whsn,err,nearest,dist,snx,sny,snth,errsel,p, ...
    isnew,allwhsn,ridfs,snapszht,snxi,snyi] = g_imdb_route_getdata( ...
    shortwhd,routenum,res,zht,useinfomax,improc,forcegen, ...
    improcforinfomax,userealsnaps,snapszht,dosave)
if nargin < 9 || isempty(userealsnaps)
    userealsnaps = true;
end
if nargin < 8 || isempty(improcforinfomax)
    improcforinfomax = false;
end
if nargin < 7
    forcegen = false;
end
if nargin < 6
    improc = '';
end

if nargin < 11
    dosave = ~forcegen;
end

getallwhsn = true;
nth = min(360,res);

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
if userealsnaps
    if userealsnaps==1
        snapstr = '';
    else
        snapstr = sprintf('_realsnaps%d',userealsnaps);
    end
else
    snapstr = sprintf('_imdbsnaps%d',snapszht);
end
figdatfn = fullfile(g_dir_imdb_routes_figdata,sprintf('wrapped_g_imdb_route_geterrs_%s%s_%03d_res%03d_z%d%s%s.mat',improcstr,shortwhd,routenum,res,zht,infomaxstr,snapstr));
ridfsfigdatfn = fullfile(g_dir_imdb_routes_ridfs_figdata,sprintf('wrapped_g_imdb_route_geterrs_%s%s_%03d_res%03d_z%d%s%s.mat',improcstr,shortwhd,routenum,res,zht,infomaxstr,snapstr));

fprintf('target file: %s\n',figdatfn);
isnew = ~exist(figdatfn,'file');
wantridfs = nargout >= 14;
haveridfs = exist(ridfsfigdatfn,'file');
if ~isnew && ~forcegen && (~wantridfs || haveridfs)
    oldsnapszht = snapszht;
    load(figdatfn);
    if ~isempty(oldsnapszht) && snapszht ~= oldsnapszht
        error(['specified snapshot height differs from the height at ' ...
               'which real snapshots were taken'])
    end
        
    if wantridfs
        load(ridfsfigdatfn);
    end
else
    if forcegen && ~isnew
        warning('generating fig data even though it already exists')
    end
    
    imfun = gantry_getimfun(improc);
    
    weight_update_count = 30;
    
    load(fullfile(whd,'im_params.mat'),'p')
    zi = find(p.zs==zht);
    if ~any(zht == p.zs)
        error('invalid height: %f',zht);
    end
    
    if userealsnaps
        oldsnapszht = snapszht;
        [snaps,~,snx,sny,snth,~,snapszht]=g_imdb_route_getrealsnaps(p.arenafn,routenum,res,imfun);
        if ~isempty(oldsnapszht) && snapszht ~= oldsnapszht
            error(['specified snapshot height differs from the height at ' ...
                   'which real snapshots were taken'])
        end
        allsnx = snx;
        allsny = sny;
        allsnth = snth;
        if userealsnaps~=1
            len = size(snaps,3);
            ind = 1:double(userealsnaps):len;
            snaps = snaps(:,:,ind);
            snx = snx(ind);
            sny = sny(ind);
            snth = snth(ind);
            fprintf('using every 1 in %d real snapshots (n=%d/%d)\n',userealsnaps,size(snaps,3),len);
        end
    else
        [snaps,snx,sny,snth]=g_imdb_route_getimdbsnaps(p.arenafn,routenum,res,imfun,shortwhd,find(snapszht==p.zs),p.imsep);
        allsnx = snx;
        allsny = sny;
        allsnth = snth;
    end
    
    valids = g_imdb_imexist(whd,p,zi);
    ind = find(valids);
    nheads = length(ind);
    [imxi,imyi] = ind2sub(size(valids),ind);
    heads = NaN(nheads,1);
    
    newsz = [size(snaps,1),size(snaps,2)];
    startprogbar(10,nheads,'calculating headings',true)
    if useinfomax
        infomax_wts = [];
        for xi = 1:weight_update_count
            infomax_wts = infomax_train(size(snaps,3), reshape(snaps,[prod(newsz), ...
                size(snaps,3)]), infomax_wts);
        end
        
        ridfs = NaN(nheads,nth);
        for i = 1:nheads
            im = g_imdb_getprocim(shortwhd,imxi(i),imyi(i),zi,imfun,res);
            [heads(i),~,cridf] = infomax_gethead(im,[],infomax_wts,[],nth);
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
            im = g_imdb_getprocim(shortwhd,imxi(i),imyi(i),zi,imfun,res);
            [heads(i),~,cwhsn,cridfs] = ridfheadmulti(im,snaps,'wta',[],nth,[],getallwhsn);
            allwhsn(i,:) = cwhsn';
            ridfs(i,:,:) = shiftdim(cridfs,-1);
            
            if progbar
                return
            end
        end
        
        whsn = allwhsn(:,1);
    end
    
    if dosave
        if ~exist(g_dir_imdb_routes_figdata,'dir')
            mkdir(g_dir_imdb_routes_figdata);
        end
        fprintf('Saving to %s...\n',figdatfn);
        save(figdatfn,'imxi','imyi','heads','whsn','allsnx','allsny','allsnth','snx','sny','snth','p','userealsnaps','snapszht','weight_update_count','zht');

        if ~exist(g_dir_imdb_routes_ridfs_figdata,'dir')
            mkdir(g_dir_imdb_routes_ridfs_figdata);
        end
        fprintf('Saving RIDFs to %s...\n\n',ridfsfigdatfn);
        save(ridfsfigdatfn,'ridfs','allwhsn');
    else
        warning('not saving data because dosave==false')
    end
end

snxi = 1+allsnx(:) / p.imsep;
snyi = 1+allsny(:) / p.imsep;

dx = bsxfun(@minus,imxi(:)',snxi);
dy = bsxfun(@minus,imyi(:)',snyi);
alldist = p.imsep * hypot(dy, dx);
[dist,nearest] = min(alldist);

% calculate error on heading (0 to 90 deg)
allsnth = allsnth(:);
target_heads = allsnth(nearest);
err = circ_dist(heads, target_heads);
err = abs(err);
err = min(pi/2,err) * 180/pi;

err_corridor = 2;

mindist = min(hypot(dx,dy));
errsel = mindist <= err_corridor;
