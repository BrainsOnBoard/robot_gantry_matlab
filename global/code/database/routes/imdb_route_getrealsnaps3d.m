function [snaps,whclick,clx,cly,clth,p,ptr]=imdb_route_getrealsnaps3d(arenafn,routenum,res,imfun)
% function [snaps,clickis,snx,sny,snth,pxsnx,pxsny,pxsnth,crop,p]=imdb_route_getsnaps3d(shortwhd,routenum,zht,res,dohisteq)

fov = 360;

routefn = sprintf('route_%s_%03d',matfileremext(arenafn),routenum);
snfn = sprintf('snaps_%s_fov%03d_imw%03d',routefn,fov,res);
load(fullfile(routes_fovsnapdir,snfn),'fovsnaps')
snaps = NaN(size(fovsnaps));
for i = 1:size(fovsnaps,3)
    snaps(:,:,i) = im2double(imfun(fovsnaps(:,:,i)));
end

load(fullfile(routes_routedir,sprintf('route_%s_%03d.mat',arenafn,routenum)),'p','clx','cly','whclick','ptr')
clth = atan2(diff(cly),diff(clx));
clth(end+1) = clth(end);