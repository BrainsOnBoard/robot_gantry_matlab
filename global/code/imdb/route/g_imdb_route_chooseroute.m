function g_imdb_route_chooseroute(dosave,shortwhd)
if nargin < 1 || isempty(dosave)
    dosave = false;
end
if nargin < 2 || isempty(shortwhd)
    whd = g_imdb_choosedb;
else
    whd = fullfile(g_dir_imdb,shortwhd);
end

[fex,p] = g_imdb_imexist(whd,[],1);

[gy,gx] = meshgrid(p.ys,p.xs);
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

objverts = g_arena_load(p.arenafn);
g_fig_drawobjverts(objverts,[],'k');

snx = [];
sny = [];
snth = [];
while true
    try
        [bx,by,but]=ginput(1);
    catch ex
        if strcmp(ex.identifier,'MATLAB:ginput:FigureDeletionPause')
            disp('Figure closed')
            return
        end
    end
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
snth = mod(snth,2*pi);
snth(end+1) = snth(end);

if dosave
    filei = 1;
    while true
        datafn = fullfile(g_dir_imdb_routes,sprintf('route_%03d.mat',filei));
        if ~exist(datafn,'file')
            break;
        end
        filei = filei + 1;
    end
    
    savemeta(datafn,'p','snx','sny','snth');
end
