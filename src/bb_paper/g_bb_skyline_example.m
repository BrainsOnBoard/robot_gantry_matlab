function g_bb_skyline_example

dosave = true;
figtype = 'pdf';
useinfomax = [false true];
improc = '';
% realsnapsel = 3;
snapszht1 = 200;
snapszht2 = 0;
zht = 0:100:500;

imdb_plants = 'green_imdb_2017-06-06_001';

%%
% % worst-matching positions - mean error
% badcoords = [600 900; 1400 800; 1600 800; 1500 800; 1500 900; 1600 900; 700 700; 1100 900; 1400 900; 1300 900];

% % worst-matching positions - max error
% badcoords = [1400 800; 1500 800; 1600 800; 1500 900; 1600 900; 1400 900; 1300 800; 1300 900; 900 900; 1000 900];

% % worst-matching positions - mean error (all)
% badcoords = [2800 800; 2700 600; 2800 600; 2800 700; 2700 500; 2800 500; 2700 700; 2700 400; 2800 900; 2800 300];

% % worst-matching positions - max error (all)
% badcoords = [2100 0; 2200 0; 2300 0; 2600 0; 2700 0; 2800 0; 0 100; 2100 100; 2200 100; 2300 100];

% % worst-matching positions - mean error (corridor)
% badcoords = [600 900; 1500 900; 1600 800; 1600 900; 1500 800; 1100 800; 700 700; 1200 900; 1100 900; 1400 900];

% worst-matching positions - max error (corridor)
badcoords = [1500 800; 1600 800; 1600 900; 1500 900; 1400 900; 1300 800; 1300 900; 1400 800; 900 900; 1000 900];

shiftridfs = false;

% goodcoords = [800 900; 700 1000; 700 900; 600 1000; 900 900; 500 1100; 600 1100; 500 1200; 1600 800; 400 1200];
if getskyline(imdb_plants,badcoords)
    return
end
g_bb_ridf(imdb_plants,1,zht,zht,false,improc,badcoords,shiftridfs,dosave,true,figtype);
g_bb_ridf(['skyline_' imdb_plants],1,zht,zht,false,improc,badcoords,shiftridfs,dosave,true,figtype);
g_bb_ridf(['skylinebg_' imdb_plants],1,zht,zht,false,improc,badcoords,shiftridfs,dosave,true,figtype);

function ret=getskyline(imdb,coords)
slimdb = fullfile(g_dir_imdb,['skyline_' imdb]);
load(fullfile(slimdb,'im_params.mat'),'p');
for i = 1:size(coords,1)
    x = find(coords(i,1)==p.xs);
    y = find(coords(i,2)==p.ys);
    fn = sprintf('im_%03d_%03d_*.png',x,y);
    if andy_skyline(imdb,fn,@stretch,false,true);
        ret = true;
        return
    end
end
ret = false;

function im=stretch(im)
% im = im2double(im);
% mins = min(im);
% range = max(im)-mins;
% im = bsxfun(@rdivide,bsxfun(@minus,im,mins),range);
im = double(im);
minval = min(im(:));
range = max(im(:))-minval;
im = im2uint8((im - minval) / range);
