% measurements taken on 19/5/2017
% arena contained a number of plastic grasses and ferns in polystyrene

xmax = 380;
ymax = 250;
coords = {[121, 51; xmax-125, 51; xmax-121, 121; 131, 106], ...
    [150, ymax-50; 147, ymax-94; xmax-148, ymax-94; xmax-147, ymax-50], ...
    [xmax-68, 80; xmax-67, ymax-120; xmax-50, ymax-93; xmax-90, ymax-47; xmax-148, ymax-73; ...
    xmax-150, ymax-95; xmax-125, 121; xmax-126, 82]};
objhts = [85, 85, 71];

% save to file
g_arena_save('arena_plants',coords,objhts);