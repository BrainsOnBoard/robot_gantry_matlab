function g_bb_skyline_fix

shortwhd = 'green_imdb_2017-06-06_001';
whd = fullfile(g_dir_imdb,shortwhd);
fgd = fullfile(g_dir_imdb,['skyline_' shortwhd]);
bgd = fullfile(g_dir_imdb,['skylinebg_' shortwhd]);
if ~exist(bgd,'dir')
    mkdir(bgd);
    copyfile(fullfile(whd,'im_params.mat'),bgd);
end
d = dir(fullfile(fgd,'*.mat'));
for i = 1:length(d)
    fn = fullfile(fgd,d(i).name);
    load(fn);
    fnpng = [d(i).name(1:end-4) '.png'];
    if varsinmatfile(fn,'x1')
        im = imread(fullfile(whd,fnpng));
        skyl = g_bb_cap_skyl(skyl,x1,x2,size(im,1));
        save(fn,'skyl','-append');
        sel = bsxfun(@lt,(1:size(im,1))',skyl);
        imfg = im;
        imfg(sel) = 255;
        
        fprintf('Saving %s...\n',fnpng)
        imwrite(imfg,fullfile(fgd,fnpng));
        
        im(~sel) = 255;
        imwrite(im,fullfile(bgd,fnpng));
    end
end
