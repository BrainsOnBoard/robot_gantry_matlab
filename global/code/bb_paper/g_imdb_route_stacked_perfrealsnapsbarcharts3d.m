function g_imdb_route_stacked_perfrealsnapsbarcharts3d(dosave,improc)
if nargin < 2
    improc = '';
end
if nargin < 1
    dosave = false;
end

useinfomax = [false true];
improcforinfomax = false;
res = 90;
shortwhd={
    'imdb_2017-02-09_001'      % open, new boxes
    %'imdb_2016-03-23_001', ... % open, empty
    };
zht = 0:100:500;
routenums = 3;
forcegen = false;

[stderrs,means] = deal(NaN(length(useinfomax),length(res),length(shortwhd),length(routenums),length(zht)));

for i = 1:length(useinfomax)
    for j = 1:length(res)
        for k = 1:length(shortwhd)
            for l = 1:length(routenums)
                for m = 1:length(zht)
                    [imxi,imyi,heads,whsn,err,nearest,dist,snx,sny,snth,errsel,p,isnew] = g_imdb_route_getdata(shortwhd{k},'arena2_pile',routenums(l),res(j),zht(m),useinfomax(i),improc,forcegen,improcforinfomax);
                    
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
g_fig_setfont

if dosave
    if ~empty(improc)
        improc(end+1) = '_';
    end
    g_fig_save([improc,'pm_inf_height'],[20 10]);
end