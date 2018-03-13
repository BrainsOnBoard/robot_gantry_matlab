function g_imdb_unwrapims(ds,procfun,fprefix)
% Unwraps all the images for stored image databases. The user shouldn't
% need to call this function.

if nargin < 1 || isempty(ds)
    d = dir(fullfile(g_dir_imdb,'wrapped_imdb_*'));
    ds = {};
    for i = 1:length(d)
        if d(i).isdir
            ds{end+1} = d(i).name;
        end
    end
elseif ~iscell(ds)
    ds = {ds};
end
if nargin < 2 || isempty(procfun)
    procfun = @gantry_processim;
end
if nargin < 3
    fprefix = '';
end

load('gantry_centrad.mat','unwrapparams')
crop = load('gantry_cropparams.mat');

switch length(ds)
    case 0
        disp('no image dbs found')
        return
    case 1
        imdbi = 1;
    otherwise
        for i = 1:length(ds)
            fprintf('%3d. %s\n',i,ds{i});
        end
        imdbi = input('Which dir [all]: ');
        if isempty(imdbi);
            imdbi = 1:length(ds);
        end
end

for i = imdbi
    fprintf('unwrapping %s...\n', ds{i})
    
    olddir = fullfile(g_dir_imdb,ds{i});
    uwdir = fullfile(g_dir_imdb,[fprefix ds{i}(9:end)]);
    if ~exist(uwdir,'dir')
        mkdir(uwdir)
    end
    paramf = fullfile(uwdir,'im_params.mat');
    if exist(paramf,'file')
        disp('(skipping)')
        continue;
    end
    copyfile(fullfile(olddir,'im_params.mat'),paramf);
    save(paramf,'unwrapparams','crop','-append')
    
    fs = dir(fullfile(olddir,'im_*_*_*.png'));
    for j = 1:length(fs)
        fr = imread(fullfile(olddir,fs(j).name));
        fr = procfun(fr,unwrapparams,crop);
        imwrite(fr,fullfile(uwdir,fs(j).name))
    end
end
