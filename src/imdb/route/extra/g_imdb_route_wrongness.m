
clear

forcegen = false;

res = 90;
shortwhd='imdb_2017-02-09_001';      % open, new boxes
zht = 0:100:500; % +50mm
routenum = 3;

for czht = zht
    [imxi,imyi,heads,whsn,err,nearest,dist,snx,sny,snth,errsel,p,isnew,allwhsn] = g_imdb_route_getdata(shortwhd,'arena2_pile',routenum,res,czht,false,forcegen);
    snx = snx * 1000/20;
    sny = sny * 1000/20;
    wrongness = hypot(sny(nearest)-sny(whsn),snx(nearest)-snx(whsn));
    
    figure
    wim = NaN(length(p.ys),length(p.xs));
    wim(sub2ind(size(wim),imyi,imxi)) = wrongness;
    wim(isnan(wim)) = max(wrongness);
    imagesc(p.xs,p.ys,wim)
    title(sprintf('z = %d mm', czht));
    colormap hot
    set(colorbar,'YLabel','wrongness')
end