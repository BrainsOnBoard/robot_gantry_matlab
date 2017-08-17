function g_imdb_unwrapims
% Unwraps all the images for stored image databases. The user shouldn't
% need to call this function.

load('gantry_centrad.mat','unwrapparams')
crop = load('gantry_cropparams.mat');

d = dir(fullfile(g_dir_imdb,'wrapped_imdb_*'));
ds = {};
for i = 1:length(d)
    if d(i).isdir
        ds{end+1} = d(i).name;
    end
end

switch length(ds)
    case 0
        disp('no image dbs found')
        return
    case 1
        whd = 1;
    otherwise
        for i = 1:length(ds)
            fprintf('%3d. %s\n',i,ds{i});
        end
        whd = input('Which dir [all]: ');
        if isempty(whd);
            whd = 1:length(ds);
        end
end

for i = whd
    fprintf('unwrapping %s...\n', ds{i})
    
    olddir = fullfile(g_dir_imdb,ds{i});
    uwdir = fullfile(g_dir_imdb,ds{i}(9:end));
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
    
    fs = dir(fullfile(olddir,'im_*_*_*.mat'));
    for j = 1:length(fs)
        load(fullfile(olddir,fs(j).name),'fr');
        fr = gantry_processim(fr,unwrapparams,crop);
        save(fullfile(uwdir,fs(j).name),'fr')
    end
end