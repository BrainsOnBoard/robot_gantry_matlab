function gantry_rf_bin_getsnapsresfov(imw,fov)
if nargin < 2
    fov = 360;
end
if nargin < 1
    imw = 90:90:360;
end

thresh = 128;

snapdir = routes_fovsnapdir;
for cimw = imw
    for cfov = fov
        d = dir(fullfile(snapdir,sprintf('snaps_route_*_fov%03d_imw%03d.mat',cfov,cimw)));
        
        for i = 1:length(d)
            outfn = fullfile(snapdir,['bin_', d(i).name]);
            if exist(outfn,'file')
                warning('file %s already exists; skipping', outfn)
                continue
            end
            
            load(fullfile(snapdir,d(i).name),'fovsnaps');
            newfovsnaps = false(size(fovsnaps));
            for j = 1:size(fovsnaps,3)
                newfovsnaps(:,:,j) = fovsnaps(:,:,j) > thresh;
                
%                 figure(1);clf
%                 subplot(2,1,1)
%                 imshow(fovsnaps(:,:,j))
%                 
%                 subplot(2,1,2)
%                 imshow(newfovsnaps(:,:,j))
%                 ginput(1);
            end
            fovsnaps = newfovsnaps;
            
            savemeta(outfn,'fovsnaps','thresh');
        end
    end
end