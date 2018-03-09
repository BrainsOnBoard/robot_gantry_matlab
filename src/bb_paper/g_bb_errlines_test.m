%%
clear

dosave = true;
figtype = 'svg';
useinfomax = [false true];
improc = '';
snapszht1 = 200;
snapszht2 = 0;
zht = 0:100:500;

useiqr = false;

imdb_pile = 'imdb_2017-02-09_001';
imdb_boxes = 'imdb_2016-03-29_001';
imdb_plants = 'imdb_2017-06-06_001';

%% errlines
% open, pile
g_bb_errlines(imdb_pile,1,zht,zht,false,useinfomax,improc,dosave, ...
    figtype,useiqr,[30 90]);

% plants
g_bb_errlines(imdb_plants,1,zht,zht,false,useinfomax,improc,dosave, ...
    figtype,useiqr,[60 90]);
