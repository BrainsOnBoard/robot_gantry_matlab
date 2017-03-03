clear

shortwhd={
    'unwrap_imdb3d_2017-02-09_001'      % open, new boxes
    %'unwrap_imdb3d_2016-03-23_001', ... % open, empty
    };
res = 90;
zht = 0:100:500;
routenum = 3;
forcegen = false;

for czht = zht
    [imxi,imyi,heads,whsn,err1,nearest,dist,snx,sny,snth,errsel,p,isnew,allwhsn] = imdb_route_getrealsnapserrs3d(shortwhd{1},'arena2_pile',routenum,res,czht,false,'',forcegen);
    [imxi,imyi,heads,whsn,err2,nearest,dist,snx,sny,snth,errsel,p,isnew,allwhsn] = imdb_route_getrealsnapserrs3d(shortwhd{1},'arena2_pile',routenum,res,czht,false,'histeq',forcegen);
    
    figure
    diffim = NaN(length(p.ys),length(p.xs));
    diffim(sub2ind(size(diffim),imyi,imxi)) = err1 - err2;
    imagesc(p.xs,p.ys,diffim);
    colormap hot
    colorbar;
    title(sprintf('none minus histeq, ht: %d',czht))
    set(gca,'YDir','normal')
    axis equal tight
end