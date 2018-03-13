function label = g_imdb_getlabel(shortwhd)
% function label = g_imdb_getlabel(shortwhd)
%
% gets the user-assigned label for an image database (e.g. what was in the
% arena etc.)

fn = fullfile(g_dir_imdb,shortwhd,'im_params.mat');
if isempty(whos('label','-file',fn))
    label = '';
else
    load(fn,'label');
end
