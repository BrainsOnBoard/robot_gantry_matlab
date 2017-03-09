clear

dosave = true;

p = load('arenadim.mat');
p.imsep = 100; % mm
p.xs = 0:p.imsep:p.lim(1);
p.ys = 0:p.imsep:p.lim(2);
p.zht = 150;
p.objgridac = 10; % mm
p.headclear = 150;
p.arenafn = 'arena1_boxes.mat';

fex = false(length(p.ys),length(p.xs));
for xi = 1:length(p.xs)
    for yi = 1:length(p.ys)
        fex(yi,xi) = exist(fullfile(imdbdir,'unwrap_imdb_2016-02-05_001',sprintf('im_%03d_%03d.mat',yi,xi)),'file');
    end
end

[gx,gy] = meshgrid(p.xs,p.ys);
ind = find(fex);
[imyi,imxi] = ind2sub(size(fex),ind);

figure(1);clf
axis equal
xlim([0 p.lim(1)])
ylim([0 p.lim(2)])
hold on
imx = gx(ind);
imy = gy(ind);
plot(gx,gy,'r.',imx,imy,'g.','MarkerSize',10)
title('Click where you want snapshots and press return to finish');

load(fullfile(g_dir_arenas,p.arenafn),'objverts');
drawobjverts(objverts,[],'k');

snx = [];
sny = [];
snth = [];
while true
    [bx,by,but]=ginput(1);
    if isempty(but)
        break
    end
    if but~=1
        continue
    end
    
    [~,nearest] = min(hypot(imx-bx,imy-by));
    cx = imx(nearest);
    cy = imy(nearest);
    snx(end+1) = 1 + cx / p.imsep;
    sny(end+1) = 1 + cy / p.imsep;
    
    plot(cx,cy,'bo');
    if length(snx) > 1
        plot([p.xs(snx(end-1)) cx], [p.ys(sny(end-1)) cy], 'b');
        
        snth(end+1) = atan2(sny(end) - sny(end-1), snx(end) - snx(end-1));
    end
end
snth(end+1) = snth(end);
snth = mod(snth,2*pi);

if dosave
    if ~exist(imdb_routedir,'dir')
        mkdir(imdb_routedir);
    end
    
    filei = 1;
    while true
        datafn = fullfile(imdb_routedir,sprintf('route_%03d.mat',filei));
        if ~exist(datafn,'file')
            break;
        end
        filei = filei + 1;
    end
    
    fprintf('Saving to %s...\n', datafn);
    save(datafn,'p','snx','sny','snth');
end
