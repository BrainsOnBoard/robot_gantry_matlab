function [snaps,whclick,clx,cly,clth,p,ptr]=g_imdb_route_getrealsnaps3d(arenafn,routenum,res)
% function [snaps,whclick,clx,cly,clth,p,ptr]=g_imdb_route_getrealsnaps3d(arenafn,routenum,res)

fov = 360;

routefn = sprintf('route_%s_%03d',matfileremext(arenafn),routenum);
snfn = sprintf('snaps_%s_fov%03d_imw%03d',routefn,fov,res);
load(fullfile(g_dir_routes_snaps,snfn),'fovsnaps')
snaps = NaN(size(fovsnaps));
for i = 1:size(fovsnaps,3)
    snaps(:,:,i) = im2double(fovsnaps(:,:,i));
end

load(fullfile(g_dir_routes,sprintf('route_%s_%03d.mat',arenafn,routenum)),'p','clx','cly','whclick','ptr')
clth = atan2(diff(cly),diff(clx));
clth(end+1) = clth(end);
