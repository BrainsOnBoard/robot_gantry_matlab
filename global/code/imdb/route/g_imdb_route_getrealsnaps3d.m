function [snaps,whclick,snx,sny,snth,p,ptr,procsnaps]=g_imdb_route_getrealsnaps3d(arenafn,routenum,res,improc)
% function [snaps,whclick,clx,cly,clth,p,ptr]=g_imdb_route_getrealsnaps3d(arenafn,routenum,res,improc)
if nargin < 4
    improc = '';
end

fov = 360;

routefn = sprintf('route_%s_%03d',matfileremext(arenafn),routenum);
snfn = sprintf('snaps_%s_fov%03d_imw%03d',routefn,fov,res);
load(fullfile(g_dir_routes_snaps,snfn),'fovsnaps')
snaps = NaN(size(fovsnaps));
for i = 1:size(fovsnaps,3)
    snaps(:,:,i) = im2double(fovsnaps(:,:,i));
end
if isempty(improc)
    procsnaps = snaps;
else
    procsnaps = NaN(size(fovsnaps));
    imfun = gantry_getimfun(improc);
    for i = 1:size(fovsnaps,3)
        procsnaps(:,:,i) = im2double(imfun(fovsnaps(:,:,i)));
    end
end

load(fullfile(g_dir_routes,sprintf('route_%s_%03d.mat',arenafn,routenum)),'p','clx','cly','whclick','ptr')
snx = clx*2*p.objgridac/p.arenascale;
sny = cly*2*p.objgridac/p.arenascale;
snth = atan2(diff(cly),diff(clx));
snth(end+1) = snth(end);
