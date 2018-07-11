function g_imdb_convert_to_new_format(shortwhd)
p = g_imdb_getparams(shortwhd);

fprintf('Processing %s...\n',shortwhd);
newname = matfileremext(p.arenafn);
newdir = fullfile(g_dir_imdb,'new',newname);
mkdir(newdir)
fid = fopen(fullfile(newdir,[newname '.csv']),'w');
if fid==-1
    error('could not open file for writing')
end
fprintf(fid,'X [mm], Y [mm], Z [mm], Heading [degrees], Filename\n');
for xi = 1:length(p.xs)
    for yi = 1:length(p.ys)
        for zi = 1:length(p.zs)
            oldpath = fullfile(g_dir_imdb,shortwhd,sprintf('im_%03d_%03d_%03d.png',xi,yi,zi));
            if ~exist(oldpath,'file')
                continue
            end
            newfn = sprintf('%s_%04d_%04d_%04d.png',newname,p.xs(xi),p.ys(yi),p.zs(zi));
            copyfile(oldpath,fullfile(newdir,newfn));
            
            fprintf(fid,'%d, %d, %d, 0, %s\n',xi-1,yi-1,zi-1,newfn);
        end
    end
end
fclose(fid);