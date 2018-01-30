clear

shortwhd = 'green_imdb_2017-06-06_001';
whd = fullfile(g_dir_imdb,['skyline_' shortwhd]);
d = dir(fullfile(whd,'*.mat'));
for i = 1:length(d)
    load(fullfile(whd,d(i).name),'skyl');
    fnpng = [d(i).name(1:end-4) '.png'];
    im = imread(fullfile(g_dir_imdb,shortwhd,fnpng));
    sel = bsxfun(@lt,(1:size(im,1))',skyl);
    im(sel) = 255;
    
    fprintf('Saving %s...\n',fnpng)
    imwrite(im,fullfile(whd,fnpng));
end
