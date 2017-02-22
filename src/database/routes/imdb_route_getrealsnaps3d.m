function [fovsnaps,whclick,clx,cly,clth,p,ptr]=imdb_route_getrealsnaps3d(arenafn,routenum,res,dohisteq)
% function [snaps,clickis,snx,sny,snth,pxsnx,pxsny,pxsnth,crop,p]=imdb_route_getsnaps3d(shortwhd,routenum,zht,res)
% clear
% arenafn = 'arena2_pile';
% routenum = 3;
% res = 90;
fov = 360;

routefn = sprintf('route_%s_%03d',matfileremext(arenafn),routenum);
if dohisteq
    histeqstr = 'histeq_';
else
    histeqstr = '';
end
snfn = sprintf('%ssnaps_%s_fov%03d_imw%03d',histeqstr,routefn,fov,res);
load(fullfile(routes_fovsnapdir,snfn),'fovsnaps')

load(fullfile(routes_routedir,sprintf('route_%s_%03d.mat',arenafn,routenum)),'p','clx','cly','whclick','ptr')
clth = atan2(diff(cly),diff(clx));
clth(end+1) = clth(end);
