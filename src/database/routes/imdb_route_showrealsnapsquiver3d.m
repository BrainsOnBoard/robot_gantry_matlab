
clear
close all

dosave = false;
showfigs = true;
newonly = false;
forcegen = false;

shortwhd={
    'unwrap_imdb3d_2017-02-09_001'      % open, new boxes
    'unwrap_imdb3d_2016-03-23_001', ... % open, empty
    };
res = [360 180 90];
zht = 0:100:500;

for useinfomax = [false true]
    for cres = res
        for i = 1:length(shortwhd)
            for routenum = 1:2
                for czht = zht
                    [imxi,imyi,heads,whsn,err,nearest,dist,snx,sny,snth,errsel,p,isnew] = imdb_route_getrealsnapserrs3d(shortwhd{i},'arena2_pile',routenum,cres,czht,useinfomax,forcegen);
                    
                    if ~showfigs || (newonly && ~isnew)
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

                    plot(p.xs(imxi(~errsel)),p.ys(imyi(~errsel)),'b+')
                    plot(p.xs(imxi(errsel)),p.ys(imyi(errsel)),'g+')
%                     anglequiver(p.xs(imxi(~errsel)),p.ys(imyi(~errsel)),heads(~errsel));
%                     anglequiver(p.xs(imxi(errsel)),p.ys(imyi(errsel)),heads(errsel),[],'g')
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
                    gantry_setfigfont
                    
                    if dosave
                        if useinfomax
                            infomaxstr = 'infomax';
                        else
                            infomaxstr = 'pm';
                        end
                        gantry_savefig(sprintf('%s_%s_route%d_res%03d_z%d_ridf_quiver%s',infomaxstr,flabel,routenum,cres,czht),[10 10]);
                    else
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
end