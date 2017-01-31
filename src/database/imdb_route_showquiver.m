
clear

dosave = true;

shortwhd = 'unwrap_imdb_2016-02-04_002';
fnum = 1;
[imxi,imyi,heads,err,dist,snx,sny,snth,p] = imdb_route_geterrs(shortwhd,fnum);

%%
whd = fullfile(imdbdir,shortwhd);
flabel = imdb_getlabel(whd);

figure(1);clf
hold on
if ~isempty(p.arenafn)
    load(fullfile(arenadir,p.arenafn));
    drawobjverts(objverts,[],'k')
end

anglequiver(p.xs(imxi),p.ys(imyi),heads);
plot(p.xs(snx),p.ys(sny),'ro','LineWidth',4,'MarkerSize',10)
axis equal tight
xlabel('x (mm)')
ylabel('y (mm)')
if dosave
    gantry_savefig([flabel '_ridf_quiver'],[10 10]);
end
