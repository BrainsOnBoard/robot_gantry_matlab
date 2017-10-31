function [snaps,whclick,snx,sny,snth,p,snapszht,procsnaps]=g_imdb_route_getrealsnaps(arenafn,routenum,res,imfun)
% function [snaps,whclick,snx,sny,snth,p,snapszht,procsnaps,arenascale]=g_imdb_route_getrealsnaps(arenafn,routenum,res,improc)

fov = 360;

routefn = sprintf('route_%s_%03d',matfileremext(arenafn),routenum);
snfn = sprintf('snaps_%s_fov%03d_imw%03d',routefn,fov,res);
load(fullfile(g_dir_routes_snaps,snfn),'fovsnaps')
snaps = NaN(size(fovsnaps));
for i = 1:size(fovsnaps,3)
    snaps(:,:,i) = im2double(fovsnaps(:,:,i));
end
if strcmp(char(imfun),'deal')
    procsnaps = snaps;
else
    procsnaps = NaN(size(fovsnaps));
    for i = 1:size(fovsnaps,3)
        procsnaps(:,:,i) = im2double(imfun(fovsnaps(:,:,i)));
    end
end

load(fullfile(g_dir_routes,routefn),'p','clx','cly','whclick','ptr')
snx = clx*1000/p.arenascale;
sny = cly*1000/p.arenascale;
snth = atan2(diff(sny),diff(snx));
snth(end+1) = snth(end);

snapszht = ptr.zht;
