function imdb_route_improc_compare(dosave)
if nargin < 1
    dosave = false;
end

useinfomax = [false true];
alglabels = { 'Perfect memory', 'Infomax' };
res = 90;
improc = { '', 'histeq', 'bin' };
improclabels = { 'None', 'histeq', 'Binarised' };
shortwhd={
    'imdb_2017-02-09_001'      % open, new boxes
    %'imdb_2016-03-23_001', ... % open, empty
    };
zht = 0:100:500;
routenums = 3;

[stderrs,means] = deal(NaN(length(useinfomax),length(res),length(shortwhd),length(routenums),length(zht),length(improc)));

for i = 1:length(useinfomax)
    for j = 1:length(res)
        for k = 1:length(shortwhd)
            for l = 1:length(routenums)
                for m = 1:length(zht)
                    for n = 1:length(improc)
                        %                     imdb_route_getrealsnapserrs3d(shortwhd{i},'arena2_pile',routenum,cres,czht,useinfomax,false);
                        [imxi,imyi,heads,whsn,err,nearest,dist,snx,sny,snth,errsel,p,isnew] = imdb_route_getrealsnapserrs3d(shortwhd{k},'arena2_pile',routenums(l),res(j),zht(m),useinfomax(i),improc{n},false);
                        
                        means(i,j,k,l,m,n) = mean(err(errsel));
                        stderrs(i,j,k,l,m,n) = stderr(err(errsel));
                    end
                end
            end
        end
    end
end

%%
cmeans = squeeze(means); % algorithm * hts * improc
cmeans(:,end+1,:) = mean(cmeans,2);
xlabels = cell(1,length(zht)+1);
for i = 1:length(zht)
    xlabels{i} = num2str(zht(i)+50);
end
xlabels{end} = 'Mean';

for i = 1:length(useinfomax)
    figure(i);clf
    h = bar(shiftdim(cmeans(i,:,:)));
%     h(1).FaceColor = 'w';
%     h(2).FaceColor = 'k';
    legend(improclabels,'Location','northwest')
    set(gca,'XTickLabel',xlabels)
    xlabel('Test height (mm)')
    ylabel('Error (deg)')
    title(alglabels{i})
    gantry_setfigfont
    
    if dosave
        gantry_savefig(sprintf('%s_%s',mfilename,alglabels{i}),[20 10]);
    end
end