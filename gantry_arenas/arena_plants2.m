function [objverts,objhts,isoffset] = arena_plants2
% measurements taken on 15/11/2017
%
% arena contained a number of plastic grasses and ferns in polystyrene and
% two cardboard boxes

xmax = 3800;
ymax = 2500;

ylo = 490;
yhi = 2091;

objverts = {
    % polystyrene, 2 branches
    [640, 600;
     640, 970;
     840, 970;
     1200, 1120;
     1200, 800;
     860, 780;
     880, 600] ...
    
    % cardboard box ("Kobuki")
    [570, 1550;
     570, yhi;
     760, yhi;
     760, 1550] ...
     
    % plants
    [1270, 0;
     1270, 500;
     1420, 500;
     1420, 740;
     xmax-1580, 710;
     xmax-1170, 0] ...
     
    % plants in centre
    [1480, 1120;
     1440, 1520;
     2030, ymax-960;
     2060, ymax-1360] ...
     
    % plants, top centre
    [1280, ymax-580;
     1280, ymax;
     2100, ymax;
     2100, ymax-500] ...
     
    % plants, top right
    [xmax-1320, ymax-940;
     xmax-1320, ymax-500;
     xmax-900, ymax-520;
     xmax-900, ymax-950]
     
    % cardboard box, bottom right
    [xmax-900, ylo;
     xmax-900, ymax-1120;
     xmax-400, ymax-1120;
     xmax-400, ylo]
    };

objhts = [740, 400, 600, 870, 840, 800, 280];
isoffset = false;