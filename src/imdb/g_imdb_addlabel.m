function g_imdb_addlabel(fprefix)
% adds a label to describe an image database (e.g. what was in the arena,
% etc.)

if ~nargin
    fprefix = '';
end

[whd,shortwhd] = g_imdb_choosedb(fprefix);
if ~iscell(whd)
    whd = {whd};
    shortwhd = {shortwhd};
end

for i = 1:length(whd)
    label = g_imdb_getlabel(shortwhd{i});
    label=input(sprintf('Enter label for %s [%s]: ',shortwhd{i},label),'s');
    if ~isempty(label)
        disp('Writing to file.')
        save(fullfile(whd{i},'im_params.mat'),'-append','label')
    end
end
