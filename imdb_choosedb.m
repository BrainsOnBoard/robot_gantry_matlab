function whd=imdb_choosedb

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
        inp = input(sprintf('Which dir [%d]: ',length(ds)));
        if isempty(inp);
            whd = ds{end};
        else
            whd = ds{inp};
        end
end

whd = fullfile(mfiledir,whd);