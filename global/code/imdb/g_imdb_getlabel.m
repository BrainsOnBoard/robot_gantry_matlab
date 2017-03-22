function label = g_imdb_getlabel(whd)
% function label = g_imdb_getlabel(whd)
%
% gets the user-assigned label for an image database (e.g. what was in the
% arena etc.)

fn = fullfile(whd,'im_params.mat');
if isempty(whos('label','-file',fn))
    label = '';
else
    load(fn,'label');
end