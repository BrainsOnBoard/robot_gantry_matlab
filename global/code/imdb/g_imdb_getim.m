function fr=g_imdb_getim(whd,x,y,z)
% function fr=g_imdb_getim(whd,x,y,z)
%
% Load an image at the specified x,y,z position from the specified
% database. The image is returned as a matrix of uint8s. x,y,z should be
% the index of the image (e.g. 1,2,3) not the position in mm (e.g.
% 100,200,300).

try
    load(fullfile(whd,sprintf('im_%03d_%03d_%03d.mat',x,y,z)))
catch ex
    if strcmp(ex.identifier,'MATLAB:load:couldNotReadFile')
        fr = [];
    else
        rethrow(ex)
    end
end