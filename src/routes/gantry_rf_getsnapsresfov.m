function gantry_rf_getsnapsresfov(imw,fov)
if nargin < 2
    fov = 360;
end
if nargin < 1
    imw = 90;
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
    for cimw = imw
        for cfov = fov
            newsz = round(cimw * [size(snaps,1)/size(snaps,2), cfov/360]);
            outfn = fullfile(snapdir,sprintf('snaps_%s_fov%03d_imw%03d.mat',matfileremext(d(i).name),cfov,cimw));
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