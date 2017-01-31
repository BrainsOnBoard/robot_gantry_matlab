function [imxi,imyi,heads,err,dist,snx,sny,snth,p]=imdb_route_geterrs(shortwhd,fnum)

whd = fullfile(imdbdir,shortwhd);

figdatfn = fullfile(imdb_route_figdatdir,sprintf('imdb_route_geterrs_%s_%03d',shortwhd,fnum));

if exist(figdatfn,'file')
    load(figdatfn);
else
    d = dir(fullfile(imdb_routedir,sprintf('*_%s_%03d.mat',shortwhd,fnum)));
    if length(d) > 1
        warning('multiple route files found');
    end
    load(fullfile(imdb_routedir,d(1).name));
    
    snaps = zeros(120,720,length(snx),'uint8');
    for i = 1:length(snx)
        snaps(:,:,i) = imdb_getim(whd,sny(i),snx(i));
    end
    
    [heads,whsn] = deal(NaN(length(imxi),1));
    startprogbar(10,length(imxi))
    for i = 1:length(imxi)
        fname = fullfile(whd,sprintf('im_%03d_%03d.mat',imyi(i),imxi(i)));
        if exist(fname,'file')
            load(fname,'fr');
            [heads(i),~,whsn(i)] = ridfheadmulti(fr,snaps,'wta');
        end
        
        if progbar
            return
        end
    end
    
    % calculate error on heading (0 to 90 deg)
    snth = snth(:);
    err = circ_dist(heads, snth(whsn));
    err = abs(err);
    err = min(pi,err) * pi/180;
    
    dx = bsxfun(@minus,imxi(:)',snx(:));
    dy = bsxfun(@minus,imyi(:)',sny(:));
    alldist = p.imsep * hypot(dy, dx);
    [dist,nearest] = min(alldist);
    
    if ~exist(imdb_route_figdatdir,'dir')
        mkdir(imdb_route_figdatdir);
    end
    save(figdatfn,'imxi','imyi','heads','err','dist','snx','sny','snth','p');
end