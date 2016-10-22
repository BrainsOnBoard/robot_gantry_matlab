clear

load(fullfile(mfiledir,'routedat','snaps_route__001_fov090.mat'))
% load('C:\Users\gantry\Desktop\alex\routedat\route_arena1_boxes_001.mat')

for i = 1:size(fovsnaps,3)
    figure(1);clf
    imshow(fovsnaps(:,:,i))
end