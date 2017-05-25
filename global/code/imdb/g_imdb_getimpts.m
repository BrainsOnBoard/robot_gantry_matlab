function [fex,p,whd] = g_imdb_getimpts(whd)
if ~nargin
    whd = g_imdb_choosedb;
end

load(fullfile(whd,'im_params.mat'))

fex = false(length(p.xs),length(p.ys),length(p.zs));
for xi = 1:length(p.xs)
    for yi = 1:length(p.ys)
        for zi = 1:length(p.zs)
            fex(xi,yi,zi) = exist(fullfile(whd,sprintf('im_%03d_%03d_%03d.mat',xi,yi,zi)),'file');
        end
    end
end