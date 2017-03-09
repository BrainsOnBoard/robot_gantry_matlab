function imdb_getridfheads(whdshort, dosave)
if nargin < 2
    dosave = false;
end
if nargin < 1 || isempty(whdshort)
    [~,whdshort] = imdb_choosedb;
end

whd = fullfile(imdbdir,whdshort);

load(fullfile(whd,'im_params.mat'));
load('gantry_cropparams.mat');

refxi = round(1+(length(p.xs)-1)/2);
refyi = round(1+(length(p.ys)-1)/2);

load(fullfile(whd,sprintf('im_%03d_%03d.mat',refyi,refxi)),'fr');
reffr = im2gray(fr(y1:y2,:));

[heads,idf] = deal(NaN(length(p.ys),length(p.xs)));
startprogbar(10,numel(idf))
for yi = 1:size(idf,1)
    for xi = 1:size(idf,2)
        fname = fullfile(whd,sprintf('im_%03d_%03d.mat',yi,xi));
        if exist(fname,'file')
            load(fname,'fr');
            [heads(yi,xi),idf(yi,xi)] = ridfhead(fr(y1:y2,:),reffr);
        end
        
        if progbar
            return
        end
    end
end

%%
flabel = imdb_getlabel(whd);

figure(2);clf
surf(p.xs,p.ys,idf)
if dosave
    gantry_savefig([flabel '_idf'], [16 10]);
end

figure(1);clf
hold on
if ~isempty(p.arenafn)
    load(fullfile(arenadir,p.arenafn));
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