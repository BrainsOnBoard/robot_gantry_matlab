clear
close all

nth = 360;
improc = '';
forcegen = false;

res = 90;
shortwhd='imdb_2017-02-09_001'; % open, new boxes
whd = fullfile(g_dir_imdb,shortwhd);
zht = 0:100:500; % +50mm
routenum = 3;

arenafn = 'arena2_pile';

%% load RIDFs
for i = 1:length(zht)
    [imxi,imyi,heads,whsn,err,nearest,dist,snx,sny,snth,errsel,p,isnew,allwhsn,ridfs] = g_imdb_route_getrealsnapserrs3d(shortwhd,arenafn,routenum,res,zht(i),false,improc,forcegen);

    bestsnap(:,i) = whsn;
    for j = 1:size(ridfs,1)
        bestridfs(j,:,i) = ridfs(j,:,whsn(j));
    end
end

%% show quiver plot
g_imdb_route_showrealsnapsquiver3d(false,false,improc,shortwhd,zht);

while true
    figure(1)
    [x,y,but] = ginput(1);
    if isempty(but)
        break
    end
    if but ~= 1
        continue
    end
    if x < 0 || x > p.lim(1) || y < 0 || y > p.lim(2)
        disp('Invalid point selected')
        continue
    end
    
    [~,xi] = min(abs(p.xs-x));
    [~,yi] = min(abs(p.ys-y));
    sel = xi==imxi & yi==imyi;
    if ~any(sel)
        disp('Invalid point selected')
        continue
    end
    
    figure(2);clf
    plot(shiftdim(bestridfs(sel,:,:)))
    xlim([0 nth])
    title(sprintf('x=%d, y=%d',p.xs(xi),p.ys(yi)))
    legend(num2str(zht'))
end