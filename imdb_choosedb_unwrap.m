function [whd,shortdn]=imdb_choosedb_unwrap

d = dir(fullfile(mfiledir,'unwrap_imdb_*'));
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
        shortdn = ds{1};
    otherwise
        for i = 1:length(ds)
            fn = fullfile(ds{i},'im_params.mat');
            load(fn)
            if isempty(whos('label','-file',fn))
                label = '';
            end
%             if isfield(p,'arenafn')
%                 if isempty(p.arenafn)
%                     arenafn = 'EMPTY ARENA';
%                 else
%                     arenafn = p.arenafn;
%                 end
%             else
%                 arenafn = 'NOT SPECIFIED';
%             end
            fprintf('%3d. %s (%s)\n',i,ds{i},label);
        end
        inp = input(sprintf('Which dir [%d]: ',length(ds)));
        if isempty(inp);
            shortdn = ds{end};
        else
            if length(inp)==1
                shortdn = ds{inp};
            else
                shortdn = ds(inp);
            end
        end
end

whd = fullfile(mfiledir,shortdn);