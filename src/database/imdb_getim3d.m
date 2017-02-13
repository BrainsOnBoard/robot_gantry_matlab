function fr=imdb_getim3d(whd,x,y,z,crop)
try
    if isempty(z)
        load(fullfile(whd,sprintf('im_%03d_%03d.mat',y,x)))
        if nargin >= 4
            fr = fr(crop.y1:crop.y2,:);
        end
    else
        load(fullfile(whd,sprintf('im_%03d_%03d_%03d.mat',x,y,z)))
    end
catch ex
    if strcmp(ex.identifier,'MATLAB:load:couldNotReadFile')
        fr = [];
    else
        rethrow(ex)
    end
end