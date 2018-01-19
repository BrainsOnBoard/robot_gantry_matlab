function g_fig_series_end(name,dodelete,figtype)
if nargin >= 3 && (~isempty(figtype) && ~strcmpi(figtype,'pdf'))
    % we can only join pdf files
    return
end

if ispc
    warning('not joining figures')
    return
end

if nargin < 2 || isempty(dodelete)
    dodelete = true;
end

global LASTFIGS

outpath = fullfile(g_dir_figures,name);
if exist(outpath,'file')
    warning('File %s already exists; overwriting',outpath)
end
stat = system(sprintf('LD_LIBRARY_PATH="" pdfunite "%s" "%s"',strjoin(LASTFIGS,'" "'),outpath));
if stat~=0
    warning('Error joining pdf files')
    return
end

fprintf('Joining pdf files: %s\n',outpath)

if dodelete
    fpath = fileparts(LASTFIGS{1});
    for i = 1:length(LASTFIGS)
        delete(LASTFIGS{i});
    end
    d = dir(fpath);
    if length(d)==2
        rmdir(fpath);
    end
end

LASTFIGS=[];
