%%
dosave = true;
useinfomax = [false true];
improc = '';

%% quivers
% open, pile
g_bb_showdata('imdb_2017-02-09_001',1,[],200,true,useinfomax,improc,true,false,true,false);

% open, boxes
g_bb_showdata('imdb_2016-03-29_001',3,[],200,false,useinfomax,improc,true,false,true,false);

%% boxplots
% open, pile
g_bb_boxplot('imdb_2017-02-09_001',1,[],0:100:500,true,useinfomax,improc,true,false);

% open, boxes
g_bb_boxplot('imdb_2016-03-29_001',3,[],0:100:500,false,useinfomax,improc,true,false);
