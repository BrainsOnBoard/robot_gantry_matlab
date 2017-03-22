
clear
close all

dosave = true;
showfigs = true;
newonly = false;

shortwhd={
    'imdb_2016-03-23_001', ... % open, empty
    'imdb_2016-03-29_001'      % open, boxes
    };
res = [360 180 90];
zht = 0:100:500;

for useinfomax = [false true]
    for cres = res
        for i = 1:length(shortwhd)
            for routenum = 1:2
                for czht = zht
                    [imxi,imyi,heads,whsn,err,nearest,dist,snx,sny,snth,errsel,p,pxsnx,pxsny,pxsnth,isnew] = g_imdb_route_geterrs3d(shortwhd{i},routenum,cres,czht,useinfomax,false);
                    
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

%                     plot(p.xs(imxi(~errsel)),p.ys(imyi(~errsel)),'b+')
%                     plot(p.xs(imxi(errsel)),p.ys(imyi(errsel)),'g+')
                    anglequiver(p.xs(imxi(~errsel)),p.ys(imyi(~errsel)),heads(~errsel));
                    anglequiver(p.xs(imxi(errsel)),p.ys(imyi(errsel)),heads(errsel),[],'g')
                    plot(p.xs(snx),p.ys(sny),'ro',p.xs(snx),p.ys(sny),'g','MarkerSize',5)
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
                    
                    if dosave
                        if useinfomax
                            infomaxstr = 'infomax';
                        else
                            infomaxstr = 'pm';
                        end
                        g_fig_save(sprintf('%s_%s_route%d_res%03d_z%d_ridf_quiver%s',infomaxstr,flabel,routenum,cres,czht),[10 10]);
                    else
                        ginput(1);
                    end
                end
            end
        end
    end
end