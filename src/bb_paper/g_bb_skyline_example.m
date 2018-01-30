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
% biggest mean diffs across snapzhts (snaps only)
goodcoords = [800 900; 700 1000; 700 900; 600 1000; 900 900; 500 1100; 600 1100; 500 1200; 1600 800; 400 1200];
if getskyline(imdb_plants,goodcoords)
    return
end
g_bb_ridf_examples(imdb_plants,1,zht,zht,improc,goodcoords,dosave,true,figtype,1);
g_bb_ridf_examples(['skyline_' imdb_plants],1,zht,zht,improc,goodcoords,dosave,true,figtype,2);
g_bb_ridf_examples(['skylinebg_' imdb_plants],1,zht,zht,improc,goodcoords,dosave,true,figtype,3);

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
