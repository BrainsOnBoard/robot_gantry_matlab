function imdb_addlabel
% clear

[whd,shortdn] = imdb_choosedb_unwrap;
if ~iscell(whd)
    whd = {whd};
    shortdn = {shortdn};
end

for i = 1:length(whd)
    label = imdb_getlabel(whd{i});
    label=input(sprintf('Enter label for %s [%s]: ',shortdn{i},label),'s');
    if ~isempty(label)
        disp('Writing to file.')
        save(fullfile(whd{i},'im_params.mat'),'-append','label')
    end
end