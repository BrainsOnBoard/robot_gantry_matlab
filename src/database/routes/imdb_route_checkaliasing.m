% function imdb_route_checkaliasing(dosave)
% if ~nargin
%     dosave = false;
% end

res = 90;
shortwhd='unwrap_imdb3d_2017-02-09_001';      % open, new boxes
zht = 400; % +50mm
routenum = 3;

[imxi,imyi,heads,whsn,err,nearest,dist,snx,sny,snth,errsel,p,isnew] = imdb_route_getrealsnapserrs3d(shortwhd,'arena2_pile',routenum,res,zht,false,false);

whsnim = NaN(length(p.ys),length(p.xs));
whsnim(sub2ind(size(whsnim),imyi,imxi)) = whsn;

figure(1);clf
imagesc(p.xs,p.ys,whsnim)
axis equal
colormap hot
colorbar

return

if dosave
    gantry_savefig('pm_inf_height',[20 10]);
end