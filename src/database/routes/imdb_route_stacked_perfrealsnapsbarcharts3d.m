function imdb_route_stacked_perfrealsnapsbarcharts3d(dosave)
if ~nargin
    dosave = false;
end

useinfomax = [false true];
res = 90;
shortwhd={
    'unwrap_imdb3d_2017-02-09_001'      % open, new boxes
    %'unwrap_imdb3d_2016-03-23_001', ... % open, empty
    };
zht = 0:100:500;
routenums = 3;

[stderrs,means] = deal(NaN(length(useinfomax),length(res),length(shortwhd),length(routenums),length(zht)));

for i = 1:length(useinfomax)
    for j = 1:length(res)
        for k = 1:length(shortwhd)
            for l = 1:length(routenums)
                for m = 1:length(zht)
%                     imdb_route_getrealsnapserrs3d(shortwhd{i},'arena2_pile',routenum,cres,czht,useinfomax,false);
                    [imxi,imyi,heads,whsn,err,nearest,dist,snx,sny,snth,errsel,p,isnew] = imdb_route_getrealsnapserrs3d(shortwhd{k},'arena2_pile',routenums(l),res(j),zht(m),useinfomax(i),false);
                    
                    means(i,j,k,l,m) = mean(err(errsel));
                    stderrs(i,j,k,l,m) = stderr(err(errsel));
                end
            end
        end
    end
end

figure(1);clf
cmeans = squeeze(means)';
h = bar(zht+50, cmeans);
h(1).FaceColor = 'w';
h(2).FaceColor = 'k';
legend({'Perfect memory','Infomax'},'Location','northwest')
xlabel('Test height (mm)')
ylabel('Error (deg)')
gantry_setfigfont

if dosave
    gantry_savefig('pm_inf_height',[20 10]);
end