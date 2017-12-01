%%
clear
dosave = true;
useinfomax = [false true];
improc = '';
realsnapsel = 3;
snapszhtall = 0:100:500;

%% quivers
% open, pile
g_bb_quiver('imdb_2017-02-09_001',1,[],200,realsnapsel,useinfomax,improc,true,false,dosave,false);

% open, boxes
g_bb_quiver('imdb_2016-03-29_001',3,[],200,false,useinfomax,improc,true,false,dosave,false);

%% boxplots
% open, pile
g_bb_boxplot('imdb_2017-02-09_001',1,[],snapszhtall,realsnapsel,useinfomax,improc,dosave,false);

% open, boxes
g_bb_boxplot('imdb_2016-03-29_001',3,[],snapszhtall,false,useinfomax,improc,dosave,false);

%% RIDFs
% % old coords
% coords = [1600 1500; 1600 1600; 1500 1600; 1900 1300; 2100 1300; 2300 1200; 2400 1100];

% % biggest diffs for snapszht=200
% coords = [1400 0; 1500 0; 1300 0; 900 200; 800 1300; 1300 100; 1400 100; 900 300; 1500 1600; 1200 0];

% biggest mean diffs across snapzhts
coords = [800 0; 2200 800; 800 100; 700 0; 700 100; 2200 900; 600 0; 1600 200; 800 200; 900 900];

% open, pile
g_bb_ridf('imdb_2017-02-09_001',1,[],snapszhtall,false,improc,coords,dosave,true);
