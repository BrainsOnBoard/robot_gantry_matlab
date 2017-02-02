function [imxi,imyi,heads,whsn,err,nearest,dist,snx,sny,snth,p]=imdb_route_geterrs(shortwhd,routenum,res,useinfomax)

whd = fullfile(imdbdir,shortwhd);

if useinfomax
    infomaxstr = '_infomax';
else
    infomaxstr = '';
end
figdatfn = fullfile(imdb_route_figdatdir,sprintf('imdb_route_geterrs_%s_%03d_res%03d_%s.mat',shortwhd,routenum,res,infomaxstr));

if exist(figdatfn,'file')
    load(figdatfn);
else
    [snaps,clickis,snx,sny,snth,crop,p]=imdb_route_getsnaps(shortwhd,routenum,res);
    
    heads = NaN(length(p.ys),length(p.xs));
    
    newsz = [size(snaps,1),size(snaps,2)];
    startprogbar(10,numel(heads))
    if useinfomax
        infomax_wts = infomax_train(size(snaps,3), reshape(snaps,[prod(newsz), size(snaps,3)]));

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
        snx = snx(clickis);
        sny = sny(clickis);
        
        for i = 1:length(p.ys)
            for j = 1:length(p.xs)
                fr = loadim(j,i);
                if ~isempty(fr)
                    [heads(i,j),~,whsn(i,j)] = ridfheadmulti(fr,snaps,'wta',[],360);
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
    err = min(pi,err) * pi/180;
    
    if ~exist(imdb_route_figdatdir,'dir')
        mkdir(imdb_route_figdatdir);
    end
    save(figdatfn,'imxi','imyi','heads','whsn','err','nearest','dist','snx','sny','snth','p');
end

    function loadedim=loadim(x,y)
        loadedim = imdb_getim(whd,y,x,crop);
        if ~isempty(loadedim)
            loadedim = imresize(loadedim,newsz,'bilinear');
        end
    end
end