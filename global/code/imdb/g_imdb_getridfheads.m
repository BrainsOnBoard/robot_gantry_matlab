function [heads,idfs,p,refxi,refyi]=g_imdb_getridfheads(whdshort,improc,res)
if nargin < 3
    res = 360;
end
if nargin < 2
    improc = @histeq;
end
if nargin < 1 || isempty(whdshort)
    [whd,whdshort] = g_imdb_choosedb;
else
    whd = fullfile(g_dir_imdb,whdshort);
end

load(fullfile(whd,'im_params.mat'));

load('arenadim.mat','lim');
[~,refxi] = min(abs(lim(1)/2-p.xs));
[~,refyi] = min(abs(lim(2)/2-p.ys));

cachedn = fullfile(g_dir_figdata,'ridfheads');
cachefn = fullfile(cachedn,sprintf('%s_p%s_r%03d.mat',whdshort,char(improc),res));
if exist(cachefn,'file')
    load(cachefn);
else
    [heads,idfs] = deal(NaN(length(p.xs),length(p.ys),length(p.zs)));
    startprogbar(10,numel(idfs))
    
    for zi = 1:length(p.zs)
        reffr = g_imdb_getprocim(whd,refxi,refyi,zi,improc,res);
        if isempty(reffr)
            error('could not get reference image at %d,%d,%d',refxi,refyi,zi);
        end
        
        for yi = 1:size(idfs,2)
            for xi = 1:size(idfs,1)
                fr = g_imdb_getprocim(whd,xi,yi,zi,improc,res);
                if ~isempty(fr)
                    [heads(xi,yi,zi),idfs(xi,yi,zi)] = ridfhead(im2double(fr),reffr);
                end
                
                if progbar
                    return
                end
            end
        end
        
        if ~exist(cachedn,'dir')
            mkdir(cachedn);
        end
        save(cachefn,'heads','idfs');
    end
end