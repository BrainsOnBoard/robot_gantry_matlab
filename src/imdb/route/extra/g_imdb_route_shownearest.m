function g_imdb_route_shownearest

close all

showfigs = true;
newonly = false;
forcegen = false;

shortwhd={
    'imdb_2017-02-09_001'      % open, new boxes
    %'imdb_2016-03-23_001', ... % open, empty
    };
res = [90 180 360];
zht = 0:100:500;
routenums = 3;

douseinfomax = [false true];

for useinfomax = douseinfomax
    for cres = res
        for i = 1:length(shortwhd)
            for routenum = routenums
                for czht = zht
                    [imxi,imyi,heads,whsn,err,nearest,dist,snx,sny,snth,errsel,p,isnew] = g_imdb_route_getdata(shortwhd{i},'arena2_pile',routenum,cres,czht,useinfomax,forcegen);
                    
                    if ~showfigs || (newonly && ~isnew)
                        continue
                    end
                    
                    whd = fullfile(g_dir_imdb,shortwhd{i});
                    flabel = g_imdb_getlabel(whd);
                    
                    figure(1);clf
                    hold on
                    if ~isempty(p.arenafn)
                        load(fullfile(g_dir_arenas,p.arenafn));
                        g_fig_drawobjverts(objverts,[],'k')
                    end
                    
                    anglequiver(p.xs(imxi),p.ys(imyi),snth(nearest));
                    plot(snx*1000/20,sny*1000/20,'ro')
                    axis equal tight
                    xlabel('x (mm)')
                    ylabel('y (mm)')
                    if useinfomax
                        methodstr = 'infomax';
                    else
                        methodstr = 'ridf';
                    end
                    title(sprintf('%s (route %d, res %d, ht %d, %s)', flabel, routenum, cres, czht, methodstr))
                    g_fig_setfont
                    
                    figure(2);clf
                    nearim = NaN(length(p.ys),length(p.xs));
                    nearim(sub2ind(size(nearim),imyi,imxi)) = nearest;
                    imagesc(p.xs,p.ys,nearim);
                    axis equal
                    colormap hot
                    colorbar
                    
                    try
                        ginput(1);
                    catch ex
                        if strcmp(ex.identifier,'MATLAB:ginput:FigureDeletionPause')
                            return
                        end
                    end
                end
            end
        end
    end
end