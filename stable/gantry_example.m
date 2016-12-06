
% initialise gantry object with a stepsize (mm) and a z height
%function g = gantry_agent(stepsize_in_mm, z)
g = gantry_agent(100, 0);

% move the gantry to a point (in mm)
g.move_to_point(500, 500);

% show starting view
figure(1);clf
subplot(2,1,1)
imshow(g.get_image)
title('starting view')

% step forward at a 45 degree angle
g.stepforward(45);

% show current view
subplot(2,1,2)
imshow(g.get_image)
title('current view')

% delete object to free resources
delete(g);