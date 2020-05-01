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

imdb_pile = 'unwrapped_2017-02-09_001';
imdb_boxes = 'unwrapped_2016-03-29_001';
imdb_plants = 'unwrapped_2017-06-06_001';

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

% %% boxplots
% % open, pile
% g_bb_boxplot(imdb_pile,1,zht,zht,false,useinfomax,improc,false,dosave,figtype);
% 
% % % open, boxes
% % g_bb_boxplot(imdb_boxes,3,zht,zht,false,useinfomax,improc,false,dosave,figtype);
% 
% % plants
% g_bb_boxplot(imdb_plants,1,zht,zht,false,useinfomax,improc,false,dosave,figtype);

%% errlines
useiqr = false;

% open, pile
g_bb_errlines(imdb_pile,1,zht,zht,false,useinfomax,improc,dosave, ...
    figtype,useiqr,[30 90]);

% plants
g_bb_errlines(imdb_plants,1,zht,zht,false,useinfomax,improc,dosave, ...
    figtype,useiqr,[60 90]);

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
% % worst-matching positions - mean error
% badcoords = [600 900; 1500 900; 1600 800; 1600 900; 1500 800; 1100 800; 700 700; 1200 900; 1100 900; 1400 900];

% worst-matching positions - max error
badcoords = [1500 800; 1600 800; 1600 900; 1500 900; 1400 900; 1300 800; 1300 900; 1400 800; 900 900; 1000 900];

% % best-matching positions - mean error
% goodcoords = [400 1300; 500 1300; 200 1400; 300 1400; 400 1400; 100 1500; 200 1500; 600 1100; 700 1100; 400 1200];

% best-matching positions - min error
goodcoords = [700 1000; 200 1300; 400 1300; 500 1300; 100 1400; 200 1400; 300 1400; 400 1400; 500 1400; 0 1500];

coords = goodcoords;

g_bb_ridf_examples(imdb_plants,1,zht,zht,improc,coords,dosave,true,figtype);
