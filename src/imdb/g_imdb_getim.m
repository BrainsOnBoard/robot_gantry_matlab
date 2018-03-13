function fr=g_imdb_getim(shortwhd,xi,yi,zi)
% function fr=g_imdb_getim(shortwhd,xi,yi,zi)
%
% Load an image at the specified x,y,z position from the specified
% database. The image is returned as a matrix of uint8s. x,y,z should be
% the index of the image (e.g. 1,2,3) not the position in mm (e.g.
% 100,200,300).

try
    fr = imread(fullfile(g_dir_imdb,shortwhd, ...
        sprintf('im_%03d_%03d_%03d.png',xi,yi,zi)));
catch ex
    if strcmp(ex.identifier,'MATLAB:imagesci:imread:fileDoesNotExist')
        fr = [];
    else
        rethrow(ex)
    end
end
