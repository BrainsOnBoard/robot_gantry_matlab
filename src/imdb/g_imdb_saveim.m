function success=g_imdb_saveim(shortwhd,xi,yi,zi,dest)
if nargin < 5
    dest = '.';
end
fn = fullfile(shortwhd,sprintf('im_%03d_%03d_%03d.png',xi,yi,zi));
success = copyfile(fullfile(g_dir_imdb,fn),dest);

fprintf('Copying im from %s to %s...\n',fn,dest);
if ~success
    error('Could not copy image')
end
