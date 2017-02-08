clear

fov = 360;
arenafn = 'arena2_pile';
routenum = 1;

imw = [90, 180, 360, 720];

snaps = cell(1,length(imw));
for i = 1:length(imw)
    load(fullfile(routes_fovsnapdir, sprintf('snaps_route_%s_%03d_fov%d_imw%03d.mat', arenafn, routenum, fov, imw(i))),'fovsnaps');
    snaps{i} = fovsnaps;
end

for i = 1:size(snaps{1},3)
    figure(1);clf
    for j = 1:length(snaps)
        subplot(length(snaps),1,j)
        imshow(snaps{j}(:,:,i))
    end
    
    x = ginput(1);
    if isempty(x)
        break
    end
end