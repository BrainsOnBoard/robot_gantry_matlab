function g_imdb_addlabel
% adds a label to describe an image database (e.g. what was in the arena,
% etc.)

[whd,shortdn] = g_imdb_choosedb;
if ~iscell(whd)
    whd = {whd};
    shortdn = {shortdn};
end

for i = 1:length(whd)
    label = g_imdb_getlabel(whd{i});
    label=input(sprintf('Enter label for %s [%s]: ',shortdn{i},label),'s');
    if ~isempty(label)
        disp('Writing to file.')
        save(fullfile(whd{i},'im_params.mat'),'-append','label')
    end
end