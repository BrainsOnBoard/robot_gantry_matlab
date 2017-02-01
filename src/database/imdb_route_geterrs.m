function [imxi,imyi,heads,whsn,err,nearest,dist,snx,sny,snth,p]=imdb_route_geterrs(shortwhd,routenum,res)

whd = fullfile(imdbdir,shortwhd);
imw = 720;

figdatfn = fullfile(imdb_route_figdatdir,sprintf('imdb_route_geterrs_%s_%03d_res%03d.mat',shortwhd,routenum,res));

if exist(figdatfn,'file')
    load(figdatfn);
else
    [snaps,snx,sny,snth,crop]=imdb_route_getsnaps(shortwhd,routenum,res);
    load(fullfile(whd,'im_params.mat'),'p');
    
    [heads,whsn] = deal(NaN(length(p.ys),length(p.xs)));
    startprogbar(10,numel(heads))
    for i = 1:length(p.ys)
        for j = 1:length(p.xs)
            fname = fullfile(whd,sprintf('im_%03d_%03d.mat',i,j));
            if exist(fname,'file')
                load(fname,'fr');
                fr2 = imresize(fr(crop.y1:crop.y2,:),[size(snaps,1),size(snaps,2)],'bilinear');
                
                [heads(i,j),~,whsn(i,j)] = ridfheadmulti(fr2,snaps,'wta',[],360);
            end

            if progbar
                return
            end
        end
    end
    
    valids = ~isnan(heads);
    heads = heads(valids);
    whsn = whsn(valids);
    
    % calculate error on heading (0 to 90 deg)
    snth = snth(:);
    err = circ_dist(heads, snth(whsn));
    err = abs(err);
    err = min(pi,err) * pi/180;
    
    [imyi,imxi] = ind2sub(size(valids),find(valids));
    
    dx = bsxfun(@minus,imxi(:)',snx(:));
    dy = bsxfun(@minus,imyi(:)',sny(:));
    alldist = p.imsep * hypot(dy, dx);
    [dist,nearest] = min(alldist);
    
    if ~exist(imdb_route_figdatdir,'dir')
        mkdir(imdb_route_figdatdir);
    end
    save(figdatfn,'imxi','imyi','heads','whsn','err','nearest','dist','snx','sny','snth','p');
end