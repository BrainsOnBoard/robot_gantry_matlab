

clear

forcegen = true;

res = 90;
shortwhd='unwrap_imdb3d_2017-02-09_001';      % open, new boxes
zht = 0:100:500; % +50mm
routenum = 3;

for czht = zht
    [imxi,imyi,heads,whsn,err,nearest,dist,snx,sny,snth,errsel,p,isnew,allwhsn] = imdb_route_getrealsnapserrs3d_debug(shortwhd,'arena2_pile',routenum,res,czht,false,forcegen);
end
