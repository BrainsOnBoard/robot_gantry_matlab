clear

fov = 360;
arenafn = 'arena2_pile';
routenum = 3;

imw = [90, 180, 360];
thresh = [0.2 0.4 0.5 0.6 0.8];

snaps = cell(1,length(imw));
for i = 1:length(imw)
    load(fullfile(routes_fovsnapdir, sprintf('snaps_route_%s_%03d_fov%d_imw%03d.mat', arenafn, routenum, fov, imw(i))),'fovsnaps');
    snaps{i} = fovsnaps;
end

for i = 1:size(snaps{1},3)
    figure(1);clf
    alsubplot(length(snaps),length(thresh)+1,1,1);
    for j = 1:length(snaps)
        csnap = im2double(snaps{j}(:,:,i));
        
        alsubplot(j,1)
        imagesc(snaps{j}(:,:,i))
        axis off
        
        for k = 1:length(thresh)
            alsubplot(j,k+1)
            imagesc(csnap > thresh(k));
            axis off
            
            if j==1
                title(sprintf('T=%d',round(255*thresh(k))))
            end
        end
    end
    
    colormap gray
    
    x = ginput(1);
    if isempty(x)
        break
    end
end