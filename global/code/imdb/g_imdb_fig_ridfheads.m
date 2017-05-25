function g_imdb_fig_ridfheads(whdshort,whz,dosave)
% function g_imdb_fig_ridfheads(whdshort,whz,dosave)
%
% Show RIDF headings for a given image database. All parameters optional.

if nargin < 3
    dosave = false;
end
if nargin < 2 || isempty(whz)
    whz = 1;
end
if nargin < 1 || isempty(whdshort)
    [whd,whdshort] = g_imdb_choosedb;
else
    whd = fullfile(g_dir_imdb,whdshort);
end

load(fullfile(whd,'im_params.mat'));

refxi = round(1+(length(p.xs)-1)/2);
refyi = round(1+(length(p.ys)-1)/2);

cachedn = fullfile(g_dir_figdata,'ridfheads');
cachefn = fullfile(cachedn,sprintf('%s_z%d.mat',whdshort,whz));
if exist(cachefn,'file')
    load(cachefn);
else
    if ~exist(cachedn,'dir')
        mkdir(cachedn);
    end
    
    reffr = im2double(g_imdb_getim(whd,refxi,refyi,whz));
    if isempty(reffr)
        error('could not get reference image at %d,%d,%d',refxi,refyi,whz);
    end

    [heads,idf] = deal(NaN(length(p.ys),length(p.xs)));
    startprogbar(10,numel(idf))
    for yi = 1:size(idf,1)
        for xi = 1:size(idf,2)
            fr = g_imdb_getim(whd,xi,yi,whz);
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

%%
flabel = g_imdb_getlabel(whd);

figure(2);clf
surf(p.xs,p.ys,idf)
if dosave
    g_fig_save([flabel '_idf'], [16 10]);
end

figure(1);clf
hold on
if ~isempty(p.arenafn)
    load(fullfile(g_dir_arenas,p.arenafn));
    g_fig_drawobjverts(objverts,[],'k')
end
anglequiver(p.xs,p.ys,heads);
plot(p.xs(refxi),p.ys(refyi),'ro','LineWidth',4,'MarkerSize',10)
axis equal tight
xlabel('x (mm)')
ylabel('y (mm)')
if dosave
    g_fig_save([flabel '_ridf_quiver'], [10 10]);
end