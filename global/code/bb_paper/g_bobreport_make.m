%%
clear

dosave = true;
useinfomax = [false true];
improc = '';
% realsnapsel = 15;
realsnapsel = false;
trainht = 400;
testht = [0 trainht];

arena_pile = 'imdb_2017-02-09_001';
arena_boxes = 'imdb_2016-03-29_001';
arena_plants = 'imdb_2017-06-06_001';

%% quivers
g_bb_quiver(arena_pile,1,testht,trainht,realsnapsel,useinfomax,improc,true,false,dosave,false);
g_bb_quiver(arena_plants,1,testht,trainht,false,useinfomax,improc,true,false,dosave,false);

%% RIDFs
% % old coords
% coords = [1600 1500; 1600 1600; 1500 1600; 1900 1300; 2100 1300; 2300 1200; 2400 1100];

% % biggest diffs for snapszht=200
% coords = [1400 0; 1500 0; 1300 0; 900 200; 800 1300; 1300 100; 1400 100; 900 300; 1500 1600; 1200 0];

% biggest mean diffs across snapzhts
coords = [800 0; 2200 800; 800 100; 700 0; 700 100; 2200 900; 600 0; 1600 200; 800 200; 900 900];

% open, pile
g_bb_ridf(arena_pile,1,[],trainht,realsnapsel,improc,coords(2,:),dosave,true);

% % biggest diffs for snapszht=200
% coords = [300 1500; 1000 800; 1200 800; 600 1600; 1100 900; 300 1600; 1000 900; 900 800; 500 700; 1100 800];

% biggest mean diffs across snapzhts
% coords = [2700 1600; 2800 1600; 2700 1500; 2800 1500; 2600 1600; 2800 300; 2500 1600; 2800 0; 2700 400; 2800 200];
g_bb_ridf(arena_plants,1,[],trainht,realsnapsel,improc,[300 1400],dosave,true);

%% boxplots
g_bb_boxplot(arena_pile,1,[],trainht,realsnapsel,useinfomax,improc,dosave,false);
g_bb_boxplot(arena_plants,1,[],trainht,false,useinfomax,improc,dosave,false);
