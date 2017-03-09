% function imdb_route_checkaliasing(dosave)
% if ~nargin
%     dosave = false;
% end
clear

res = 90;
shortwhd='unwrap_imdb3d_2017-02-09_001';      % open, new boxes
zht = 400; % +50mm
routenum = 3;

[imxi,imyi,heads,whsn,err_infomax,nearest,dist,snx,sny,snth,errsel,p,isnew] = imdb_route_getrealsnapserrs3d(shortwhd,'arena2_pile',routenum,res,zht,true,false);
[imxi,imyi,heads,whsn,err_pm,nearest,dist,snx,sny,snth,errsel,p,isnew] = imdb_route_getrealsnapserrs3d(shortwhd,'arena2_pile',routenum,res,zht,false,false);

[errim_infomax,errim_pm] = deal(NaN(length(p.ys),length(p.xs)));
errim_infomax(sub2ind(size(errim_infomax),imyi,imxi)) = err_infomax;
errim_pm(sub2ind(size(errim_pm),imyi,imxi)) = err_pm;

figure(1);clf
subplot(3,1,1)
imagesc(errim_pm)
colormap hot

subplot(3,1,2)
imagesc(errim_infomax)
colormap hot

subplot(3,1,3)
imagesc(errim_pm - errim_infomax)
colormap hot
colorbar
