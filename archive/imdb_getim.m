function fr=imdb_getim(whd,y,x,crop)
try
    load(fullfile(whd,sprintf('im_%03d_%03d.mat',y,x)))

    if nargin >= 4
        fr = fr(crop.y1:crop.y2,:);
    end
catch ex
    if strcmp(ex.identifier,'MATLAB:load:couldNotReadFile')
        fr = [];
    else
        rethrow(ex)
    end
end