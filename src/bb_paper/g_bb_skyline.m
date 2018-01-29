function g_bb_skyline

shortwhd = 'green_imdb_2017-06-06_001';
load(fullfile(g_dir_imdb,shortwhd,'im_params.mat'),'p');
tic
for i = 1:length(p.zs)
    if andy_skyline(shortwhd,sprintf('*_%03d.png',i),@stretch,false)
        break
    end
end
toc

function im=stretch(im)
% im = im2double(im);
% mins = min(im);
% range = max(im)-mins;
% im = bsxfun(@rdivide,bsxfun(@minus,im,mins),range);
im = double(im);
minval = min(im(:));
range = max(im(:))-minval;
im = im2uint8((im - minval) / range);
