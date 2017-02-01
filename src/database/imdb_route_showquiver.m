
clear

dosave = true;

shortwhd={
    'unwrap_imdb_2016-02-04_002', ... % empty, open
    'unwrap_imdb_2016-02-09_002', ... % empty, closed
    'unwrap_imdb_2016-02-09_001', ... % boxes, open
    'unwrap_imdb_2016-02-05_001'      % boxes, closed
    };
res = [360 180 90];

for cres = res
    for i = 1:length(shortwhd)
        for routenum = 1:2
            [imxi,imyi,heads,whsn,err,nearest,dist,snx,sny,snth,p] = imdb_route_geterrs(shortwhd{i},routenum,cres);
            
            whd = fullfile(imdbdir,shortwhd{i});
            flabel = imdb_getlabel(whd);
            
            figure(1);clf
            hold on
            if ~isempty(p.arenafn)
                load(fullfile(arenadir,p.arenafn));
                drawobjverts(objverts,[],'k')
            end
            
            anglequiver(p.xs(imxi),p.ys(imyi),heads);
            plot(p.xs(snx),p.ys(sny),'ro',p.xs(snx),p.ys(sny),'g','MarkerSize',5)
            axis equal tight
            xlabel('x (mm)')
            ylabel('y (mm)')
            title(sprintf('%s (route %d, res %d)', flabel, routenum, cres))
            
            if dosave
                gantry_savefig(sprintf('%s_res%03d_route%d_ridf_quiver',flabel,cres,routenum),[10 10]);
            else
                ginput(1);
            end
        end
    end
end