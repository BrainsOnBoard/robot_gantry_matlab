function g_imdb_fig_ridfheads(whdshort,whz,improc,res,dosave)
% function g_imdb_fig_ridfheads(whdshort,whz,improc,res,dosave)
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
if nargin < 1 || isempty(whdshort)
    [whd,whdshort] = g_imdb_choosedb;
else
    whd = fullfile(g_dir_imdb,whdshort);
end

load(fullfile(whd,'im_params.mat'));
if nargin < 2 || isempty(whz)
    whz = 1:length(p.zs);
end

close all

load('arenadim.mat','lim');
[~,refxi] = min(abs(lim(1)/2-p.xs));
[~,refyi] = min(abs(lim(2)/2-p.ys));

flabel = g_imdb_getlabel(whd);

cachedn = fullfile(g_dir_figdata,'ridfheads');
cachefn = fullfile(cachedn,sprintf('%s_p%s_r%03d.mat',whdshort,char(improc),res));
if exist(cachefn,'file')
    load(cachefn);
else
    [heads,idf] = deal(NaN(length(p.xs),length(p.ys),length(p.zs)));
    startprogbar(10,numel(idf))
    
    for zi = 1:length(p.zs)
        reffr = g_imdb_getprocim(whd,refxi,refyi,zi,improc,res);
        if isempty(reffr)
            error('could not get reference image at %d,%d,%d',refxi,refyi,zi);
        end
        
        for yi = 1:size(idf,2)
            for xi = 1:size(idf,1)
                fr = g_imdb_getprocim(whd,xi,yi,zi,improc,res);
                if ~isempty(fr)
                    [heads(xi,yi,zi),idf(xi,yi,zi)] = ridfhead(im2double(fr),reffr);
                end
                
                if progbar
                    return
                end
            end
        end
        
        if ~exist(cachedn,'dir')
            mkdir(cachedn);
        end
        save(cachefn,'heads','idf');
    end
end

for czi = whz(:)'
    ptitle = sprintf('improc = %s, res = %d, height = %d mm',char(improc), res, p.zs(czi));
    
    figure(numel(whz)+czi);clf
    surf(p.xs,p.ys,idf(:,:,czi))
    title(ptitle)
    if dosave
        g_fig_save([flabel '_idf'], [16 10]);
    end
    
    figure(czi);clf
    hold on
    if ~isempty(p.arenafn)
        load(fullfile(g_dir_arenas,p.arenafn));
        g_fig_drawobjverts(objverts,[],'k')
    end
    anglequiver(p.xs,p.ys,heads(:,:,czi)');
    plot(p.xs(refxi),p.ys(refyi),'ro','LineWidth',4,'MarkerSize',10)
    axis equal tight
    xlabel('x (mm)')
    ylabel('y (mm)')
    title(ptitle)
    if dosave
        g_fig_save([flabel '_ridf_quiver'], [10 10]);
    end
end