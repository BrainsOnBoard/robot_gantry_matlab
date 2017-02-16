function [fovsnaps,whclick,clx,cly,clth,p,ptr]=imdb_route_getrealsnaps3d(arenafn,routenum,res)
% function [snaps,clickis,snx,sny,snth,pxsnx,pxsny,pxsnth,crop,p]=imdb_route_getsnaps3d(shortwhd,routenum,zht,res)
% clear
% arenafn = 'arena2_pile';
% routenum = 3;
% res = 90;
fov = 360;

routefn = sprintf('route_%s_%03d',matfileremext(arenafn),routenum);
snfn = sprintf('snaps_%s_fov%03d_imw%03d',routefn,fov,res);
load(fullfile(routes_fovsnapdir,snfn),'fovsnaps')

load(fullfile(routes_routedir,sprintf('route_%s_%03d.mat',arenafn,routenum)),'p','clx','cly','whclick','ptr')
clth = atan2(diff(clx),diff(cly));
clth(end+1) = clth(end);
