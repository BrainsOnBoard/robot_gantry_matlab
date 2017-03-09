
clear

forcegen = false;

res = 90;
shortwhd='unwrap_imdb3d_2017-02-09_001';      % open, new boxes
zht = 0:100:500; % +50mm
routenum = 3;

figure(1);clf
hold on
for czht = zht
    [imxi,imyi,heads,whsn,err,nearest,dist,snx,sny,snth,errsel,p,isnew,allwhsn] = imdb_route_getrealsnapserrs3d(shortwhd,'arena2_pile',routenum,res,czht,false,forcegen);
    
    ranks = NaN(numel(nearest),1);
    for i = 1:length(ranks)
        ranks(i) = find(allwhsn(i,:)==nearest(i));
    end
    plot(ranks)
    xlim([1 length(nearest)])
end