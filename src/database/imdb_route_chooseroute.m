clear

dosave = true;

[whd,shortwhd,label] = imdb_choosedb;
load(fullfile(whd,'im_params.mat'))

fex = false(length(p.ys),length(p.xs));
for xi = 1:length(p.xs)
    for yi = 1:length(p.ys)
        fex(yi,xi) = exist(fullfile(whd,sprintf('im_%03d_%03d.mat',yi,xi)),'file');
    end
end

[gx,gy] = meshgrid(p.xs,p.ys);
ind = find(fex);

figure(1);clf
axis equal
xlim([0 p.lim(1)])
ylim([0 p.lim(2)])
hold on
imx = gx(ind);
imy = gy(ind);
plot(gx,gy,'r.',imx,imy,'g.','MarkerSize',10)
title('Click where you want snapshots and press return to finish');

if ~isempty(p.arenafn)
    load(fullfile(arenadir,p.arenafn),'objverts');
    drawobjverts(objverts,[],'k');
end

rx = [];
ry = [];
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
    plot(cx,cy,'bo');
    if ~isempty(rx)
        plot([p.xs(rx(end)) cx], [p.ys(ry(end)) cy], 'b');
    end
    
    rx(end+1) = 1 + cx / p.imsep;
    ry(end+1) = 1 + cy / p.imsep;
end

if dosave
    if ~exist(imdb_routedir,'dir')
        mkdir(imdb_routedir);
    end
    
    filei = 1;
    while true
        datafn = fullfile(imdb_routedir,sprintf('%s_%s_%03d.mat',label,shortwhd,filei));
        if ~exist(datafn,'file')
            break;
        end
        filei = filei + 1;
    end
    
    fprintf('Saving to %s...\n', datafn);
    save(datafn,'p','shortwhd','rx','ry','unwrapparams');
end