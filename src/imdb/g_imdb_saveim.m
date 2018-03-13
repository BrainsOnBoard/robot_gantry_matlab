function success=g_imdb_saveim(shortwhd,xi,yi,zi,dest)
if nargin < 5
    dest = '.';
end
fn = fullfile(g_dir_imdb,shortwhd,sprintf('im_%03d_%03d_%03d.png',xi,yi,zi));
success = copyfile(fn,dest);
