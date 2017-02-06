function gantry_rf_getsnapsfov(fov)
if ~nargin
    fov = 90:90:360;
end

d = dir(fullfile(routes_routedir,'route_*.mat'));
snapdir = routes_fovsnapdir;
if ~exist(snapdir,'dir')
    mkdir(snapdir);
end

for i = 1:length(d)
    cfn = fullfile(routes_routedir,d(i).name);
    if ~varsinmatfile(cfn,'snaps')
        warning('snaps not found in %s. skipping.',cfn)
        continue
    end
    
    load(cfn,'snaps','clx','cly');
    snths = atan2(diff(cly),diff(clx));
    sninds = round(snths*size(snaps,2)/(2*pi));
    sninds(end+1) = sninds(end);
    for f = fov
        outfn = fullfile(snapdir,sprintf('snaps_%s_fov%03d.mat',matfileremext(d(i).name),f));
%         if exist(outfn,'file')
%             error('file %s already exists',outfn)
%         end
        
        sz = [size(snaps,1),round(size(snaps,2)*f/360),size(snaps,3)];
        fovsnaps = zeros(sz,'uint8');
        for j = 1:sz(3)
            fovsnaps(:,:,j) = cshiftcut(snaps(:,:,j),sz(2),sninds(j));
        end
        savemeta(outfn,'fovsnaps');
    end
end