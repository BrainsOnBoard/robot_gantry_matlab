function g_bb_skyline_fix

shortwhd = 'green_imdb_2017-06-06_001';
whd = fullfile(g_dir_imdb,['skyline_' shortwhd]);
d = dir(fullfile(whd,'*.mat'));
for i = 1:length(d)
    fn = fullfile(whd,d(i).name);
    load(fn);
    fnpng = [d(i).name(1:end-4) '.png'];
    ffnpng = fullfile(whd,fnpng);
    if varsinmatfile(fn,'x1')
        im = imread(ffnpng);
        skyl = g_bb_cap_skyl(skyl,x1,x2,size(im,1));
        save(fn,'skyl','-append');
        sel = bsxfun(@lt,(1:size(im,1))',skyl);
        im(sel) = 255;
        
        fprintf('Saving %s...\n',fnpng)
        imwrite(im,fullfile(whd,fnpng));
    elseif exist(ffnpng,'file')
        fprintf('Deleting %s...\n',fnpng);
        delete(ffnpng);
    end
end
