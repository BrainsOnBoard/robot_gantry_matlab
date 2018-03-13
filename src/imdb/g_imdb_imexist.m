function [fex,p,shortwhd] = g_imdb_imexist(shortwhd,p,zis)
if nargin < 1 || isempty(shortwhd)
    [~,shortwhd] = g_imdb_choosedb;
end
if nargin < 2 || isempty(p)
    p = g_imdb_getparams(shortwhd);
end
if nargin < 3
    zis = 1:length(p.zs);
else
    zis = zis(:)';
end

whd = fullfile(g_dir_imdb,shortwhd);
fex = false(length(p.xs),length(p.ys),length(zis));
for xi = 1:length(p.xs)
    for yi = 1:length(p.ys)
        for i = 1:length(zis)
            fex(xi,yi,i) = exist(fullfile(whd, ...
                sprintf('im_%03d_%03d_%03d.png',xi,yi,zis(i))),'file');
        end
    end
end
