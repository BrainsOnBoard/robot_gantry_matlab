%%
dosave = true;
useinfomax = [false true];
improc = '';
realsnapsel = 3;

%% quivers
% open, pile
g_bb_showdata('imdb_2017-02-09_001',1,[],200,realsnapsel,useinfomax,improc,true,false,dosave,false);

% open, boxes
g_bb_showdata('imdb_2016-03-29_001',3,[],200,false,useinfomax,improc,true,false,dosave,false);

%% boxplots
% open, pile
g_bb_boxplot('imdb_2017-02-09_001',1,[],0:100:500,realsnapsel,useinfomax,improc,dosave,false);

% open, boxes
g_bb_boxplot('imdb_2016-03-29_001',3,[],0:100:500,false,useinfomax,improc,dosave,false);

%% RIDFs
% open, pile
coords = [1600 1500; 1600 1600; 1500 1600; 1900 1300; 2100 1300; 2300 1200; 2400 1100];
g_bb_ridf('imdb_2017-02-09_001',1,[],[],realsnapsel,improc,coords,dosave,true);
