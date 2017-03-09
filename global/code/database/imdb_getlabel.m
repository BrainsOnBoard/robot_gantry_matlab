function label = imdb_getlabel(whd)
fn = fullfile(whd,'im_params.mat');
if isempty(whos('label','-file',fn))
    label = '';
else
    load(fn,'label');
end