function [whd,whdshort,label]=imdb_choosedb3d

d = dir(fullfile(mfiledir,'unwrap_imdb3d_*'));
ds = {};
labels = {};
for i = 1:length(d)
    if d(i).isdir
        ds{end+1} = d(i).name;
        labels{end+1} = imdb_getlabel(fullfile(mfiledir,d(i).name));
    end
end

switch length(ds)
    case 0
        disp('no image dbs found')
        return
    case 1
        whdshort = ds{1};
        label = labels{1};
    otherwise
        for i = 1:length(ds)
            if isempty(labels{i})
                fprintf('%3d. %s\n',i,ds{i});
            else
                fprintf('%3d. %s (%s)\n',i,ds{i},labels{i});
            end
        end
        inp = input(sprintf('Which dir [%d]: ',length(ds)));
        if isempty(inp);
            whdshort = ds{end};
            label = labels{end};
        else
            whdshort = ds{inp};
            label = labels{inp};
        end
end

whd = fullfile(mfiledir,whdshort);