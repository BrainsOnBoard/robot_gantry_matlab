function g_imdb_route_checkridfs_height(dosave)
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

% fixed coordinates to save RIDFs for if dosave==true
coords = [1600 1500; 1600 1600; 1500 1600; 1900 1300; 2100 1300; 2300 1200; 2400 1100];

%% load RIDFs
for i = 1:length(zht)
    [imxi,imyi,heads,whsn,err,nearest,dist,snx,sny,snth,errsel,p,isnew,allwhsn,ridfs] = g_imdb_route_getdata(shortwhd,arenafn,routenum,imsz(2),zht(i),false,improc,forcegen);
    
    bestsnap(:,i) = whsn;
    for j = 1:size(ridfs,1)
        bestridfs(j,:,i) = ridfs(j,:,whsn(j));
    end
end
bestridfs = bestridfs/prod(imsz);

%%
imfun = gantry_getimfun(improc);
[snaps,~,snx,sny,snth]=g_imdb_route_getrealsnaps(arenafn,routenum,imsz(2),improc);

if dosave
    for i = 1:size(coords,1)
        xi = find(p.xs==coords(i,1));
        yi = find(p.ys==coords(i,2));
        sel = xi==imxi & yi==imyi;
        
        showridfs(coords(i,1),coords(i,2),xi,yi,bestridfs(sel,:,:),bestsnap(sel,:),zht,snx,sny,snaps,imfun,whd,imsz(2),p)
        saverealsnapsridfs(coords(i,1),coords(i,2))
    end
else
    g_imdb_route_showrealsnapsquiver3d(false,false,improc,shortwhd,zht);
    while true
        figure(1)
        try
            [x,y,but] = ginput(1);
        catch ex
            if strcmp(ex.identifier,'MATLAB:ginput:FigureDeletionPause')
                break
            end
            rethrow(ex)
        end
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
            
            showridfs(gx,gy,xi,yi,bestridfs(sel,:,:),bestsnap(sel,:),zht,snx,sny,snaps,imfun,whd,imsz(2),p)
        elseif but=='s'
            saverealsnapsridfs(gx,gy);
        end
    end
end

function showridfs(gx,gy,xi,yi,bestridfs,bestsnap,zht,snx,sny,snaps,imfun,whd,res,p)
fprintf('selecting point (%d,%d)\n',gx,gy)

figure(2);clf
alsubplot(3+length(zht),2,1:2,1:2)
plot(shiftdim(bestridfs(1,:,:)))
xlim([0 size(bestridfs,2)])
title(sprintf('x=%d, y=%d',gx,gy))
title(legend(num2str((zht+50)')),'Height (mm)')

colormap gray

sndist = hypot(gx-snx,gy-sny);
[~,snnearest] = min(sndist);
alsubplot(3,1:2)
imagesc(snaps(:,:,snnearest))
ylabel(snnearest)

for i = 1:length(zht)
    im = g_imdb_getprocim(whd,xi,yi,find(p.zs==zht(i)),imfun,res);
    alsubplot(3+i,1)
    imagesc(im)
    ylabel(zht(i)+50)
    
    alsubplot(3+i,2)
    whsn = bestsnap(1,i);
    imagesc(snaps(:,:,whsn));
    ylabel(whsn)
end

function saverealsnapsridfs(gx,gy)
figure(2)
g_fig_save(sprintf('ridf_%04d_%04d',gx,gy),[30 30]);