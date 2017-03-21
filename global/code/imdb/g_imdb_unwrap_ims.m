function g_imdb_unwrap_ims

load('gantry_centrad.mat','unwrapparams')
crop = load('gantry_cropparams.mat');

d = dir(fullfile(mfiledir,'imdb_*'));
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
        whd = ds{1};
    otherwise
        for i = 1:length(ds)
            fprintf('%3d. %s\n',i,ds{i});
        end
        inp = input('Which dir [all]: ');
        if isempty(inp);
            whd = 1:length(ds);
        end
end

for i = whd
    disp(ds{i})
    olddir = fullfile(mfiledir,ds{i});
    uwdir = fullfile(mfiledir,['unwrap_' ds{i}]);
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
    
    fs = dir(fullfile(olddir,'im_*_*.mat'));
    for j = 1:length(fs)
        load(fullfile(olddir,fs(j).name),'fr');
        fr = circshift(fliplr(andy_unwrap(rgb2gray(fr),unwrapparams)),0.25*size(unwrapparams.xM,2),2);
        save(fullfile(uwdir,fs(j).name),'fr')
    end
end