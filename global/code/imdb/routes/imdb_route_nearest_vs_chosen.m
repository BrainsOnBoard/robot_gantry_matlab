
clear

forcegen = false;

res = 90;
shortwhd='imdb_2017-02-09_001';      % open, new boxes
zht = 0:100:500; % +50mm
routenum = 3;

figure(1);clf
hold on
for czht = zht
    [imxi,imyi,heads,whsn,err,nearest,dist,snx,sny,snth,errsel,p,isnew,allwhsn] = imdb_route_getrealsnapserrs3d(shortwhd,'arena2_pile',routenum,res,czht,false,forcegen);
    
    [snear,I] = sort(nearest(errsel));
    swhsn = whsn(errsel);
    swhsn = swhsn(I);
    plot(snear,swhsn);
    xlabel('nearest')
    ylabel('chosen')
end
legend(num2str(zht(:)));
