clear

whd = imdb_choosedb;

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
figure(2);clf
surf(p.xs,p.ys,idf)

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