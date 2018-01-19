%%
clear

dosave = true;
useinfomax = false; %[false true];
improc = '';
% realsnapsel = 3;
realsnapsel = false;
snapszhtall = [0 100 400 500];
zht = snapszhtall;

arena_pile = 'imdb_2017-02-09_001';
arena_boxes = 'imdb_2016-03-29_001';
arena_plants = 'imdb_2017-06-06_001';

%% quivers
% open, pile
g_bb_quiver(arena_pile,1,zht,snapszhtall,realsnapsel,useinfomax,improc,true,false,false,dosave);

% % open, boxes
% g_bb_quiver(arena_boxes,3,zht,snapszhtall,false,useinfomax,improc,true,false,false,dosave);

% plants
g_bb_quiver(arena_plants,1,zht,snapszhtall,realsnapsel,useinfomax,improc,true,false,false,dosave);

%% boxplots
% open, pile
g_bb_boxplot(arena_pile,1,zht,snapszhtall,false,useinfomax,improc,false,dosave);

% % open, boxes
% g_bb_boxplot(arena_boxes,3,zht,snapszhtall,false,useinfomax,improc,false,dosave);

% plants
g_bb_boxplot(arena_plants,1,zht,snapszhtall,false,useinfomax,improc,false,dosave);

%% RIDFs
% % biggest diffs for snapszht=200
% coords = [400 1300; 200 1400; 200 1500; 300 1300; 300 1400; 1200 900; 1400 900; 1300 900; 100 1500; 1000 900];

% % biggest mean diffs across snapzhts
% coords = [800 900; 700 1000; 700 900; 600 1000; 900 900; 500 1100; 600 1100; 500 1200; 1600 800; 400 1200];
coords = [800 900];

% open, pile
g_bb_ridf(arena_plants,1,zht,snapszhtall,false,improc,coords,dosave,true);
