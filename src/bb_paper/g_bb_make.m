%%
clear

dosave = true;
figtype = 'svg';
useinfomax = [false true];
improc = '';
% realsnapsel = 3;
snapszht1 = 200;
snapszht2 = 0;
zht = 0:100:500;

doquiver = true;
dowhsn = false;

imdb_pile = 'imdb_2017-02-09_001';
imdb_boxes = 'imdb_2016-03-29_001';
imdb_plants = 'imdb_2017-06-06_001';

%% quivers 1
% open, pile
g_bb_quiver(imdb_pile,1,zht,snapszht1,false,useinfomax,improc,doquiver,dowhsn,false,dosave,figtype);

% % open, boxes
% g_bb_quiver(imdb_boxes,3,zht,snapszht1,false,useinfomax,improc,doquiver,dowhsn,false,dosave,figtype);

% plants
g_bb_quiver(imdb_plants,1,zht,snapszht1,false,useinfomax,improc,doquiver,dowhsn,false,dosave,figtype);

%% quivers 2
% open, pile
g_bb_quiver(imdb_pile,1,zht,snapszht2,false,useinfomax,improc,doquiver,dowhsn,false,dosave,figtype);

% % open, boxes
% g_bb_quiver(imdb_boxes,3,zht,snapszht2,false,useinfomax,improc,doquiver,dowhsn,false,dosave,figtype);

% plants
g_bb_quiver(imdb_plants,1,zht,snapszht2,false,useinfomax,improc,doquiver,dowhsn,false,dosave,figtype);

%% boxplots
% open, pile
g_bb_boxplot(imdb_pile,1,zht,zht,false,useinfomax,improc,false,dosave,figtype);

% % open, boxes
% g_bb_boxplot(imdb_boxes,3,zht,zht,false,useinfomax,improc,false,dosave,figtype);

% plants
g_bb_boxplot(imdb_plants,1,zht,zht,false,useinfomax,improc,false,dosave,figtype);

%% RIDFs for pile
% % old coords
% coords = [1600 1500; 1600 1600; 1500 1600; 1900 1300; 2100 1300; 2300 1200; 2400 1100];

% % biggest diffs for snapszht=200
% coords = [1400 0; 1500 0; 1300 0; 900 200; 800 1300; 1300 100; 1400 100; 900 300; 1500 1600; 1200 0];

% % biggest mean diffs across snapzhts
% coords = [800 0; 2200 800; 800 100; 700 0; 700 100; 2200 900; 600 0; 1600 200; 800 200; 900 900];

% % open, pile
% g_bb_ridf_examples(imdb_pile,1,zht,zht,false,improc,coords,dosave,true,figtype);

%% RIDFS for plants world
% % biggest diffs for snapszht=200 (snaps only)
% coords = [400 1300; 200 1400; 200 1500; 300 1300; 300 1400; 1200 900; 1400 900; 1300 900; 100 1500; 1000 900];

% biggest mean diffs across snapzhts (snaps only)
coords = [800 900; 700 1000; 700 900]; %; 600 1000; 900 900; 500 1100; 600 1100; 500 1200; 1600 800; 400 1200];

g_bb_ridf_examples(imdb_plants,1,zht,zht,improc,coords,dosave,true,figtype);
