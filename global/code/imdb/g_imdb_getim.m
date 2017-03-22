function fr=g_imdb_getim(whd,x,y,z)
try
    load(fullfile(whd,sprintf('im_%03d_%03d_%03d.mat',x,y,z)))
catch ex
    if strcmp(ex.identifier,'MATLAB:load:couldNotReadFile')
        fr = [];
    else
        rethrow(ex)
    end
end