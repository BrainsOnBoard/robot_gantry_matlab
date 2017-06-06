function g_imdb_fig_ridfheads(whdshort,improc,res,whz,dosave)
% function g_imdb_fig_ridfheads(whdshort,whz,improc,res,dosave)
%
% Show RIDF headings for a given image database. All parameters optional.

if nargin < 5
    dosave = false;
end
if nargin < 3 || isempty(res)
    res = 360;
end
if nargin < 2 || isempty(improc)
    improc = @histeq;
end
if nargin < 1 || isempty(whdshort)
    [whd,whdshort] = g_imdb_choosedb;
else
    whd = fullfile(g_dir_imdb,whdshort);
end

load(fullfile(whd,'im_params.mat'));
if nargin < 4 || isempty(whz)
    whz = 1:length(p.zs);
end

close all
flabel = g_imdb_getlabel(whd);

[heads,idfs,p,refxi,refyi] = g_imdb_getridfheads(whdshort,improc,res);

for czi = whz(:)'
    ptitle = sprintf('improc = %s, res = %d, height = %d mm',char(improc), res, p.zs(czi));
    
    figure(numel(whz)+czi);clf
    surf(p.xs,p.ys,idfs(:,:,czi)')
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