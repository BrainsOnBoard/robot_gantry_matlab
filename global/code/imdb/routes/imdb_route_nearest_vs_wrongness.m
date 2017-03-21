
clear

forcegen = false;

res = 360;
shortwhd='imdb_2017-02-09_001';      % open, new boxes
zht = 0:100:500; % +50mm
routenum = 3;

figure(1);clf
hold on
for czht = zht
    [imxi,imyi,heads,whsn,err,nearest,dist,snx,sny,snth,errsel,p,isnew,allwhsn] = imdb_route_getrealsnapserrs3d(shortwhd,'arena2_pile',routenum,res,czht,false,forcegen);
    snx = snx * 1000/20;
    sny = sny * 1000/20;
    wrongness = hypot(sny(nearest)-sny(whsn),snx(nearest)-snx(whsn));
    
    [snear,I] = sort(nearest(errsel));
    wrongness = wrongness(errsel);
    wrongness = wrongness(I);
    
    plot(snear,wrongness)
end
legend(num2str(zht(:)));
