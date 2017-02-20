% function imdb_route_checkaliasing(dosave)
% if ~nargin
%     dosave = false;
% end

forcegen = false;

res = 90;
shortwhd='unwrap_imdb3d_2017-02-09_001';      % open, new boxes
zht = 200; % +50mm
routenum = 3;

[imxi,imyi,heads,whsn,err,nearest,dist,snx,sny,snth,errsel,p,isnew,allwhsn] = imdb_route_getrealsnapserrs3d(shortwhd,'arena2_pile',routenum,res,zht,false,forcegen);

whsnim = NaN(length(p.ys),length(p.xs));
whsnim(sub2ind(size(whsnim),imyi,imxi)) = allwhsn(:,1);

figure(1);clf
imagesc(p.xs,p.ys,whsnim)
axis equal
colormap hot
colorbar

return

if dosave
    gantry_savefig('pm_inf_height',[20 10]);
end