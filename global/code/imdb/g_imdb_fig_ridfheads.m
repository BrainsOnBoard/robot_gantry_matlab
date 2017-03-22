function g_imdb_fig_ridfheads(whdshort,whz,dosave)
if nargin < 3
    dosave = false;
end
if nargin < 2
    whz = 1;
end
if nargin < 1 || isempty(whdshort)
    whd = g_imdb_choosedb;
else
    whd = fullfile(g_dir_imdb,whdshort);
end

load(fullfile(whd,'im_params.mat'));

refxi = round(1+(length(p.xs)-1)/2);
refyi = round(1+(length(p.ys)-1)/2);

reffr = im2double(g_imdb_getim(whd,refxi,refyi,whz));

[heads,idf] = deal(NaN(length(p.ys),length(p.xs)));
startprogbar(10,numel(idf))
for yi = 1:size(idf,1)
    for xi = 1:size(idf,2)
        fr = g_imdb_getim(whd,refxi,refyi,whz);
        if ~isempty(fr)
            [heads(yi,xi),idf(yi,xi)] = ridfhead(im2double(g_imdb_getim(whd,xi,yi,whz)),reffr);
        end
        
        if progbar
            return
        end
    end
end

%%
flabel = g_imdb_getlabel(whd);

figure(2);clf
surf(p.xs,p.ys,idf)
if dosave
    gantry_savefig([flabel '_idf'], [16 10]);
end

figure(1);clf
hold on
if ~isempty(p.arenafn)
    load(fullfile(g_dir_arenas,p.arenafn));
    drawobjverts(objverts,[],'k')
end
anglequiver(p.xs,p.ys,heads);
plot(p.xs(refxi),p.ys(refyi),'ro','LineWidth',4,'MarkerSize',10)
axis equal tight
xlabel('x (mm)')
ylabel('y (mm)')
if dosave
    gantry_savefig([flabel '_ridf_quiver'], [10 10]);
end