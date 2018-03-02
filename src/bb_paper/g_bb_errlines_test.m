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

%% errlines
% open, pile
g_bb_errlines(imdb_pile,1,zht,zht,false,useinfomax,improc,false,dosave,figtype);

% plants
g_bb_errlines(imdb_plants,1,zht,zht,false,useinfomax,improc,false,dosave,figtype);
