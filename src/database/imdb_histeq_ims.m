function imdb_histeq_ims(shortwhd)
if nargin
    whd = fullfile(imdbdir,shortwhd);
else
    [whd,shortwhd] = imdb_choosedb3d;
end

im_params_fn = fullfile(whd,'im_params.mat');
load(im_params_fn,'p')

outdir = fullfile(imdbdir,['histeq_', shortwhd]);
if exist(outdir,'dir')
    error('directory %s already exists',outdir)
end
mkdir(outdir)

copyfile(im_params_fn,fullfile(outdir,'im_params.mat'));

startprogbar(10,length(p.xs)*length(p.ys)*length(p.zs),'performing histeq on images',true)
for xi = 1:length(p.xs)
    for yi = 1:length(p.ys)
        for zi = 1:length(p.zs)
            fn = sprintf('im_%03d_%03d_%03d.mat',xi,yi,zi);
            ffn = fullfile(whd,fn);
            if ~exist(ffn,'file')
                if progbar
                    return
                end
                continue
            end
            
            load(ffn,'fr')
%             oldfr = fr;
            fr = histeq(fr);
            save(fullfile(outdir,fn),'fr')
            
%             figure(1);clf
%             alsubplot(2,1,1,1)
%             imshow(oldfr)
%             alsubplot(2,1)
%             imshow(fr)
%             ginput(1);
            
            if progbar
                return
            end
        end
    end
end
