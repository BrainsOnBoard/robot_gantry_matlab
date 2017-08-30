function [objverts,objhts,isoffset] = arena_plants
% measurements taken on 19/5/2017
% arena contained a number of plastic grasses and ferns in polystyrene

xmax = 3800;
ymax = 2500;

% x and y offsets, from edge of arena to masking tape crosses
offs = [570 490];

objverts = {[1210, 510; xmax-1250, 510; xmax-1210, 1210; 1310, 1060], ...
    [1500, ymax-500; 1470, ymax-940; xmax-1480, ymax-940; xmax-1470, ymax-500], ...
    [xmax-680, 800; xmax-670, ymax-1200; xmax-500, ymax-930; xmax-900, ymax-470; xmax-1480, ymax-730; ...
    xmax-1500, ymax-950; xmax-1250, 1210; xmax-1260, 820]};

b=cellfun(@(x)bsxfun(@minus,x,offs),objverts,'UniformOutput',false);
objhts = [850, 850, 710];
isoffset = false;