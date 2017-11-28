function g_bb_ridf(shortwhd,routenum,zht,snapszht,userealsnaps,improc,coords,dosave,joinpdfs)
close all

if nargin < 1 || isempty(shortwhd)
    shortwhd='imdb_2017-02-09_001';  % open, pile
%     shortwhd='imdb_2016-03-29_001'; % open, boxes
%     shortwhd='imdb_2016-02-08_003'; % closed, boxes (z=250mm)
%     shortwhd='imdb_2017-06-06_001'; % closed, plants
end
if nargin < 2 || isempty(routenum)
    routenum = 1;
end
if nargin < 3 || isempty(zht)
    zht = 0:100:500; % +50mm
end
if nargin < 4 || isempty(snapszht)
    snapszht = 200; % +50mm
end
if nargin < 5 || isempty(userealsnaps)
    userealsnaps = false;
end
if nargin < 6 || isempty(improc)
    improc = '';
end
if nargin < 7
    coords = [];
end
if nargin < 8 || isempty(dosave)
    dosave = false;
end
if nargin < 9 || isempty(joinpdfs)
    joinpdfs = false;
end

forcegen = false;

imsz = [7 90];
whd = fullfile(g_dir_imdb,shortwhd);

%% load RIDFs
% extract best-matching snaps and RIDFs and put into cell array (because
% the dimensions differ)
[bestsnap,bestridfs,imxyi] = deal(cell(length(zht),1));
for i = 1:length(zht)
    [imxi,imyi,~,whsn,~,~,~,~,~,~,~,p,~,~,ridfs] = g_imdb_route_getdata( ...
        shortwhd,routenum,imsz(2),zht(i),false,improc,forcegen,[], ...
        userealsnaps,snapszht);
    
    imxyi{i} = [imxi, imyi];
    bestsnap{i} = whsn;
    bestridfs{i} = NaN(length(imxi),imsz(2));
    for j = 1:size(ridfs,1)
        bestridfs{i}(j,:) = ridfs(j,:,whsn(j)) / prod(imsz);
    end
end

%%
imfun = gantry_getimfun(improc);

if userealsnaps
    [snaps,~,snx,sny]=g_imdb_route_getrealsnaps(p.arenafn,routenum,imsz(2),imfun);
else
    [snaps,snx,sny]=g_imdb_route_getimdbsnaps(p.arenafn,routenum,imsz(2),imfun,shortwhd,find(p.zs==snapszht),p.imsep);
end

if isempty(improc)
    improcstr = '';
else
    improcstr = [improc '_'];
end
flabel = g_imdb_getlabel(fullfile(g_dir_imdb,shortwhd));

if ~isempty(coords) % empty coords signals interactive mode
    if joinpdfs
        g_fig_series_start
    end
    for i = 1:size(coords,1)
        % get corresponding grid coords
        xi = find(p.xs==coords(i,1));
        yi = find(p.ys==coords(i,2));
        
        [cridfs,cbestsnap]=getbest(xi,yi);
        showridfs(coords(i,1),coords(i,2),xi,yi,cridfs,cbestsnap,zht,snx,sny,snaps,imfun,whd,imsz(2),p,~dosave)
        if dosave
            g_fig_save(sprintf('ridf_%s_%s%sres%03d_route%03d_snapszht%03d_x%04d_y%04d', ...
                flabel,improcstr,'pm_',imsz(2),routenum,snapszht,coords(i,1),coords(i,2)),[30 30],[],[],[],joinpdfs);
        end
    end
    if joinpdfs
        g_fig_series_end(sprintf('ridf_%s_%s%sres%03d_route%03d_snapszht%03d.pdf', ...
            flabel,improcstr,'pm_',imsz(2),routenum,snapszht),[30 30]);
    end
else
    % show quiver plot to click on
    g_bb_quiver(shortwhd,routenum,zht,snapszht,userealsnaps,false,improc,true,false);
    
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
        
        if but==1 % left mouse button
            if x < 0 || x > p.lim(1) || y < 0 || y > p.lim(2)
                disp('Invalid point selected')
                continue
            end
            
            % get nearest point on grid to click
            [~,xi] = min(abs(p.xs-x));
            [~,yi] = min(abs(p.ys-y));
            gx = p.xs(xi);
            gy = p.ys(yi);
            
            [cridfs,cbestsnap]=getbest(xi,yi);
            showridfs(gx,gy,xi,yi,cridfs,cbestsnap,zht,snx,sny,snaps,imfun,whd,imsz(2),p,false)
        elseif but=='s'
            g_fig_save(sprintf('ridf_%s_%s%sres%03d_route%03d_snapszht%03d_x%04d_y%04d', ...
                flabel,improcstr,'pm_',imsz(2),routenum,snapszht,coords(i,1),coords(i,2)),[30 30]);
        end
    end
end

    function [ridfs,snaps]=getbest(xi,yi)
        ridfs = NaN(imsz(2),length(zht));
        snaps = NaN(length(zht),1);
        for besti = 1:length(zht)
            cind = find(all(bsxfun(@eq,imxyi{besti},[xi yi]),2),1);
            if isempty(cind)
                break
            end
            
            ridfs(:,besti) = bestridfs{besti}(cind,:);
            snaps(besti) = bestsnap{besti}(cind);
        end
    end
end

function showridfs(gx,gy,xi,yi,cridfs,cbestsnap,zht,snx,sny,snaps,imfun,whd,res,p,doseparateplots)
fprintf('selecting point (%d,%d)\n',gx,gy)

if doseparateplots
    figure
else
    figure(2);clf
end
alsubplot(3+length(zht),2,1:2,1:2)
plot(cridfs)
xlim([1 size(cridfs,1)])
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
    whsn = cbestsnap(i);
    imagesc(snaps(:,:,whsn));
    ylabel(whsn)
end

end
