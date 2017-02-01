function [imxi,imyi,heads,whsn,err,nearest,dist,snx,sny,snth,p]=imdb_route_geterrs(shortwhd,routenum)

whd = fullfile(imdbdir,shortwhd);

figdatfn = fullfile(imdb_route_figdatdir,sprintf('imdb_route_geterrs_%s_%03d.mat',shortwhd,routenum));

if exist(figdatfn,'file')
    load(figdatfn);
else

    load(fullfile(imdb_routedir,sprintf('route_%03d.mat',routenum)),'snx','sny','snth');
    crop = load('gantry_cropparams.mat');
    load(fullfile(whd,'im_params.mat'),'p');
    
    snaps = zeros(crop.y2 - crop.y1 + 1,720,length(snx),'uint8');
%     figure(1);clf
    for i = 1:length(snx)
        csnap = imdb_getim(whd,sny(i),snx(i),crop);
        snaps(:,:,i) = circshift(csnap,round(snth(i) * 360 / pi),2);
        
%         ind = 2*(i-1)+1;
%         subplot(length(snx),2,ind);
%         imshow(csnap)
%         subplot(length(snx),2,ind+1);
%         imshow(snaps(:,:,i));
%         title(sprintf('angle: %f',snth(i)*180/pi));
    end
%     keyboard
    
    [heads,whsn] = deal(NaN(length(p.ys),length(p.xs)));
    startprogbar(10,numel(heads))
    for i = 1:length(p.ys)
        for j = 1:length(p.xs)
            fname = fullfile(whd,sprintf('im_%03d_%03d.mat',i,j));
            if exist(fname,'file')
                load(fname,'fr');
                [heads(i,j),~,whsn(i,j)] = ridfheadmulti(fr(crop.y1:crop.y2,:),snaps,'wta',[],360);
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