%%
clear
close all

nth = 360;
improc = '';
forcegen = false;

imsz = [7 90];
shortwhd='imdb_2017-02-09_001'; % open, new boxes
whd = fullfile(g_dir_imdb,shortwhd);
zht = 0:100:500; % +50mm
routenum = 3;

arenafn = 'arena2_pile';

%% load RIDFs
for i = 1:length(zht)
    [imxi,imyi,heads,whsn,err,nearest,dist,snx,sny,snth,errsel,p,isnew,allwhsn,ridfs] = g_imdb_route_getrealsnapserrs3d(shortwhd,arenafn,routenum,imsz(2),zht(i),false,improc,forcegen);
    
    bestsnap(:,i) = whsn;
    for j = 1:size(ridfs,1)
        bestridfs(j,:,i) = ridfs(j,:,whsn(j));
    end
end
bestridfs = bestridfs/prod(imsz);

%% show quiver plot
g_imdb_route_showrealsnapsquiver3d(false,false,improc,shortwhd,zht);

imfun = gantry_getimfun(improc);
[snaps,~,snx,sny,snth]=g_imdb_route_getrealsnaps3d(arenafn,routenum,imsz(2),improc);
while true
    figure(1)
    [x,y,but] = ginput(1);
    if isempty(but)
        break
    end
    
    if but==1
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
        
        gx = p.xs(xi);
        gy = p.ys(yi);
        fprintf('selecting point (%d,%d)\n',gx,gy)
        
        figure(2);clf
        alsubplot(2+length(zht),2,1:2,1:2)
        plot(shiftdim(bestridfs(sel,:,:)))
        xlim([0 nth])
        title(sprintf('x=%d, y=%d',gx,gy))
        title(legend(num2str((zht+50)')),'Height (mm)')
        
        for i = 1:length(zht)
            im = g_imdb_getprocim(whd,xi,yi,find(p.zs==zht(i)),imfun,imsz(2));
            alsubplot(2+i,1)
            imshow(im)
            ylabel(zht(i)+50)
            
            alsubplot(2+i,2)
            whsn = bestsnap(sel,i);
            imshow(snaps(:,:,whsn));
            ylabel(whsn)
        end
    elseif but=='s'
        figure(2)
        g_fig_save(sprintf('ridf_%04d_%04d',p.xs(xi),p.ys(yi)),[20 15]);
    end
end