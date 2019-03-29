function [whd,shortwhd,label]=g_imdb_choosedb(fprefix)
% function [whd,shortwhd,label]=g_imdb_choosedb(fprefix)
%
% gets the directory name (and label) for an image database chosen by the
% user

if ~nargin
    fprefix = '';
end

ddir = g_dir_imdb;
d = dir(fullfile(ddir,[fprefix 'unwrapped_*']));

if isempty(d)
    error('no image databases found');
end

ds = {};
labels = {};
arenafns = {};
for i = 1:length(d)
    if d(i).isdir
        ds{end+1} = d(i).name;
        labels{end+1} = g_imdb_getlabel(d(i).name);
        load(fullfile(ddir,d(i).name,'im_params.mat'),'p');
        arenafns{end+1} = p.arenafn;
    end
end

switch length(ds)
    case 0
        disp('no image dbs found')
        return
    case 1
        shortwhd = ds{1};
        label = labels{1};
    otherwise
        for i = 1:length(ds)
            lbl = labels{i};
            arena = matfileremext(arenafns{i});
            if ~isempty(arena)
                if isempty(lbl)
                    lbl = arena;
                else
                    lbl = [arena ' | ' lbl];
                end
            end
            if isempty(lbl)
                fprintf('%3d. %s\n',i,ds{i});
            else
                fprintf('%3d. %s (%s)\n',i,ds{i},lbl);
            end
        end
        inp = input(sprintf('Which dir [%d]: ',length(ds)));
        if isempty(inp)
            shortwhd = ds{end};
            label = labels{end};
        else
            shortwhd = ds{inp};
            label = labels{inp};
        end
end

whd = fullfile(ddir,shortwhd);