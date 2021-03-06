
clear

forcegen = false;

res = 90;
shortwhd='imdb_2017-02-09_001';      % open, new boxes
zht = 0:100:500; % +50mm
routenum = 3;

figure(1);clf
hold on
for czht = zht
    [imxi,imyi,heads,whsn,err,nearest,dist,snx,sny,snth,errsel,p,isnew,allwhsn] = g_imdb_route_getdata(shortwhd,'arena2_pile',routenum,res,czht,false,forcegen);
    
    rankscore = NaN(size(allwhsn,2),1);
    for i = 1:length(rankscore)
        ranks = NaN(size(allwhsn,2),1);
        for j = 1:size(allwhsn,1)
            ranks(j) = find(allwhsn(j,:)==i);
        end
        rankscore(i) = size(allwhsn,2) - mean(ranks);
    end
    plot(rankscore)
    xlim([1 length(rankscore)])
end