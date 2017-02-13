
clear
close all

dosave = true;
showfigs = true;

shortwhd={
    'unwrap_imdb3d_2016-03-23_001', ... % open, empty
    'unwrap_imdb3d_2016-03-29_001'      % open, boxes
    };
res = [360 180 90];
zht = 0:100:500;

for useinfomax = [false true]
    for cres = res
        for i = 1:length(shortwhd)
            for routenum = 1:2
                for czht = zht
                    [imxi,imyi,heads,whsn,err,nearest,dist,snx,sny,snth,errsel,p,pxsnx,pxsny,pxsnth] = imdb_route_geterrs3d(shortwhd{i},routenum,cres,czht,useinfomax,false);
                    
                    %                 figure(10);clf
                    %                 plot(imxi,imyi,'g.',imxi(errsel),imyi(errsel),'b.',snx,sny,'ro',pxsnx,pxsny,'k+')
                    %                 return
                    
                    if ~showfigs
                        continue
                    end
                    
                    whd = fullfile(imdbdir,shortwhd{i});
                    flabel = imdb_getlabel(whd);
                    
                    figure(1);clf
                    hold on
                    if ~isempty(p.arenafn)
                        load(fullfile(arenadir,p.arenafn));
                        drawobjverts(objverts,[],'k')
                    end
                    
                    %                 plot(p.xs(imxi(~errsel)),p.ys(imyi(~errsel)),'b+')
                    %                 plot(p.xs(imxi(errsel)),p.ys(imyi(errsel)),'g+')
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
                    gantry_setfigfont
                    
                    if dosave
                        if useinfomax
                            infomaxstr = '_infomax';
                        else
                            infomaxstr = '_pm';
                        end
                        gantry_savefig(sprintf('%s_route%d_res%03d_z%d_ridf_quiver%s',flabel,routenum,cres,czht,infomaxstr),[10 10]);
                    else
                        ginput(1);
                    end
                end
            end
        end
    end
end