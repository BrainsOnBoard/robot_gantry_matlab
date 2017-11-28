function g_route_getsnaps(res,fov,arenafn,routenum)
% for working fov version of code (without res param though) see
% g_live_getsnapsfov

if nargin < 3
    d = dir(fullfile(g_dir_routes,'route_*.mat'));
    fns = {d.name};
else
    fns = {sprintf('route_%s_%03d.mat',matfileremext(arenafn),routenum)};
end
if nargin < 2 || isempty(fov)
    fov = 360;
end
if nargin < 1 || isempty(res)
    res = [90 180 360];
end

snapdir = g_dir_routes_snaps;
if ~exist(snapdir,'dir')
    mkdir(snapdir);
end

for i = 1:length(fns)
    cfn = fullfile(g_dir_routes,fns{i});
    if ~varsinmatfile(cfn,'snaps')
        warning('snaps not found in %s. skipping.',fns{i})
        continue
    end
    
    load(cfn,'snaps','clx','cly');
    snths = atan2(diff(cly),diff(clx));
    sninds = round(snths*size(snaps,2)/(2*pi));
    sninds(end+1) = sninds(end);
    for cimw = res
        for cfov = fov
            newsz = round(cimw * [size(snaps,1)/size(snaps,2), cfov/360]);
            outfn = fullfile(snapdir,sprintf('snaps_%s_fov%03d_imw%03d.mat',matfileremext(fns{i}),cfov,cimw));
            if exist(outfn,'file')
                warning('file %s already exists, skipping...',outfn)
                continue
            end
            
            sz = [newsz,size(snaps,3)];
            fovsnaps = zeros(sz,'uint8');
            for j = 1:sz(3)
                % TODO: make this work for other FOVs
                shiftim = cshiftcut(snaps(:,:,j),size(snaps,2),sninds(j));
%                 figure(1);clf
%                 imshow(shiftim)
                
                fovsnaps(:,:,j) = imresize(shiftim,newsz,'bilinear');
            end
            savemeta(outfn,'fovsnaps');
        end
    end
end