function g_bb_ridf_examples(shortwhd,routenum,zht,snapszht,improc,coords,dosave,joinpdfs,figtype,figno)
% close all

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
else
    zht = sort(zht);
end
if nargin < 4 || isempty(snapszht)
    snapszht = 200; % +50mm
else
    snapszht = sort(snapszht);
end
if nargin < 5 || isempty(improc)
    improc = '';
end
if nargin < 6
    coords = [];
end
if nargin < 7 || isempty(dosave)
    dosave = false;
end
if nargin < 8 || isempty(joinpdfs)
    joinpdfs = false;
end
if nargin < 9 || isempty(figtype)
    figtype = 'pdf';
end
if nargin < 10 || isempty(figno)
    figno = 1;
end

p = g_imdb_getparams(shortwhd);

imsz = [7 90];
imfun = gantry_getimfun(improc);

sprows = max(1,ceil(length(snapszht)/3));
spcols = min(3,length(snapszht));
figsz = [18 15];

if dosave
    figure(figno)
    if joinpdfs
        g_fig_series_start
    end
end
for i = 1:size(coords,1)
    cfigno = i+(figno-1)*100;
    fprintf('Figure %d: [%d %d]\n',cfigno,coords(i,:))
    if ~dosave
        figure(cfigno)
    end
    clf
    hold on
    
    ymax = 0;
    for j = 1:length(snapszht)
        ims = NaN([imsz,length(zht)]);
        for k = 1:length(zht)
            xi = 1+coords(i,1)/p.imsep;
            yi = 1+coords(i,2)/p.imsep;
            zi = find(zht(k)==p.zs);
            fr = g_imdb_getprocim(shortwhd,xi,yi,zi,imfun,imsz(2));
            if isempty(fr)
                error('could not get im %d,%d,%d',xi,yi,zi);
            end
            ims(:,:,k) = fr;
        end
        [~,~,~,ridfs] = ridfheadmulti(ims(:,:,zht==snapszht(j)),ims);
        ridfs = ridfs / prod(imsz);
        ridfs = circshift(ridfs(end:-1:1,:),floor(size(ridfs,1)/2));
        ridfs(end+1,:) = ridfs(1,:);

        ths = repmat(linspace(-180,180,size(ridfs,1))',1,size(ridfs,2));

        subplot(sprows,spcols,j);
        h=plot(ths,ridfs);
        h(zht==snapszht(j)).LineStyle='--';
        xlim([-180 180])
        set(gca,'XTick',-180:90:180)
        xlabel('Angle (deg)')
        title(sprintf('Training height: %d mm',snapszht(j)+50))
        
%         if j==(sprows*spcols)
%             leg = legend(num2str((zht+50)'));
%             set(leg,'Location','SouthEast');
%             title(leg,'Height (mm)')
%         end

        g_fig_setfont
        andy_setbox
        
        yl = ylim;
        ymax = max(yl(2),ymax);
    end
    for j = 1:length(snapszht)
        subplot(sprows,spcols,j)
        ylim([0 ymax])
    end
    
    if dosave
        g_fig_save(sprintf('example_ridf_%s_x%04d_y%04d', ...
            shortwhd,coords(i,1),coords(i,2)), ...
            figsz,figtype,[],[],joinpdfs);
    end
end
if dosave && joinpdfs
    g_fig_series_end(['example_ridf_' shortwhd '.pdf'],true,figtype);
end
