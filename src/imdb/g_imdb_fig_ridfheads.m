function g_imdb_fig_ridfheads(shortwhd,zi,improc,res,dosave)
% function g_imdb_fig_ridfheads(shortwhd,zi,improc,res,dosave)
%
% Show RIDF headings for a given image database. All parameters optional.

if nargin < 5
    dosave = false;
end
if nargin < 4
    res = 360;
end
if nargin < 3
    improc = @histeq;
end
if nargin < 1 || isempty(shortwhd)
    [~,shortwhd] = g_imdb_choosedb;
end

p = g_imdb_getparams(shortwhd);
if nargin < 2 || isempty(zi)
    zi = 1:length(p.zs);
end

close all

load('arenadim.mat','lim');
[~,refxi] = min(abs(lim(1)/2-p.xs));
[~,refyi] = min(abs(lim(2)/2-p.ys));

flabel = g_imdb_getlabel(shortwhd);

cachedn = fullfile(g_dir_figdata,'ridfheads');
if ~exist(cachedn,'dir')
    mkdir(cachedn);
end
for czi = zi(:)'
    cachefn = fullfile(cachedn,sprintf('%s_z%d_p%s_r%03d.mat',shortwhd,czi,char(improc),res));
    if exist(cachefn,'file')
        load(cachefn);
    else
        reffr = g_imdb_getprocim(shortwhd,refxi,refyi,czi,improc,res);
        if isempty(reffr)
            error('could not get reference image at %d,%d,%d',refxi,refyi,czi);
        end
        
        [heads,idf] = deal(NaN(length(p.ys),length(p.xs)));
        startprogbar(10,numel(idf))
        for yi = 1:size(idf,1)
            for xi = 1:size(idf,2)
                fr = g_imdb_getprocim(shortwhd,xi,yi,czi,improc,res);
                if ~isempty(fr)
                    [heads(yi,xi),idf(yi,xi)] = ridfhead(im2double(fr),reffr);
                end
                
                if progbar
                    return
                end
            end
        end
        
        save(cachefn,'heads','idf');
    end
    
    ptitle = sprintf('improc = %s, res = %d, height = %d mm',char(improc),res,p.zs(czi));
    
    figure(numel(zi)+czi);clf
    surf(p.xs,p.ys,idf)
    title(ptitle)
    if dosave
        g_fig_save([flabel '_idf'], [16 10]);
    end
    
    figure(czi);clf
    hold on
    if ~isempty(p.arenafn)
        load(fullfile(g_dir_arenas,p.arenafn));
        g_arena_drawobjverts(objverts,[],'k')
    end
    anglequiver(p.xs,p.ys,heads);
    plot(p.xs(refxi),p.ys(refyi),'ro','LineWidth',4,'MarkerSize',10)
    axis equal tight
    xlabel('x (mm)')
    ylabel('y (mm)')
    title(ptitle)
    if dosave
        g_fig_save([flabel '_ridf_quiver'], [10 10]);
    end
end
