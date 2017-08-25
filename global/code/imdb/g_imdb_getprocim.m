function im=g_imdb_getprocim(whd,x,y,z,imfun,res)
if nargin < 5
    imfun = @deal;
end
if nargin < 6
    res = 720;
end

docache = res ~= 720 || ~strcmp(char(imfun),'deal');
if docache
    [~,shortwhd] = fileparts(whd);
    dname = fullfile(g_dir_cache_procim,shortwhd,char(imfun));
    imfn = fullfile(dname,sprintf('im_%03d_%03d_%03d.mat',x,y,z));
    if exist(imfn,'file')
        load(imfn,'im')
        return
    end
end

im = g_imdb_getim(whd,x,y,z);
if isempty(im)
    return
end

if res ~= 720;
    im = imresize(im,round([res*size(im,1)/size(im,2), res]),'bilinear');
end
im = im2double(imfun(im));

if docache
    if ~exist(dname,'dir')
        mkdir(dname)
    end
    save(imfn,'im');
end