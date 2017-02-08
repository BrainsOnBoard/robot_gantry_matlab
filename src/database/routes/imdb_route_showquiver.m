
clear

dosave = false;
showfigs = true;

shortwhd={
    'unwrap_imdb_2016-02-04_002', ... % empty, open
    'unwrap_imdb_2016-02-09_002', ... % empty, closed
    'unwrap_imdb_2016-02-09_001', ... % boxes, open
    'unwrap_imdb_2016-02-05_001'      % boxes, closed
    };
res = [360 180 90];

for useinfomax = [false true]
    for cres = res
        for i = 1:length(shortwhd)
            for routenum = 1:2
                [imxi,imyi,heads,whsn,err,nearest,dist,snx,sny,snth,errsel,p] = imdb_route_geterrs(shortwhd{i},routenum,cres,useinfomax,false);
                
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
                title(sprintf('%s (route %d, res %d, %s) (err: %g, std: %g)', flabel, routenum, cres, methodstr, mean(err(errsel)), std(err(errsel))))
                
                if dosave
                    if useinfomax
                        infomaxstr = '_infomax';
                    else
                        infomaxstr = '';
                    end
                    gantry_savefig(sprintf('%s_res%03d_route%d_ridf_quiver%s',flabel,cres,routenum,infomaxstr),[10 10]);
                else
                    ginput(1);
                end
            end
        end
    end
end