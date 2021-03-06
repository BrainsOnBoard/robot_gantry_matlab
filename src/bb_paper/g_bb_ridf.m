function g_bb_ridf(shortwhd,routenum,zht,snapszht,userealsnaps,improc, ...
    coords,shiftridfs,dosave,joinpdfs,figtype,doautoridf,dointeractive, ...
    headings,errs,allerrs,fprefix,pubgrade,ridfx360,skipexisting)

if nargin < 1 || isempty(shortwhd)
    [~,shortwhd] = g_imdb_choosedb;
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
    snapszht = 0:100:500; % +50mm
else
    snapszht = sort(snapszht);
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
if nargin < 8 || isempty(shiftridfs)
    shiftridfs = true;
end
if nargin < 9 || isempty(dosave)
    dosave = false;
end
if nargin < 11 || isempty(figtype)
    figtype = 'pdf';
end
if nargin < 10 || isempty(joinpdfs)
    joinpdfs = strcmpi(figtype,'pdf');
end
if nargin < 12 || isempty(doautoridf)
    doautoridf = false;
end
if nargin < 13 || isempty(dointeractive)
    dointeractive = isempty(coords);
end
if nargin < 17
    fprefix = '';
end
if nargin < 18
    pubgrade = false;
end
if nargin < 19
    ridfx360 = false;
end
if nargin < 20
    skipexisting = false;
end

if userealsnaps && length(snapszht) > 1
    % this may change...
    error('cannot have real snapshots and multiple snapszht')
end

if ~ismatrix(coords) || size(coords,2)~=2
    error('coords must be an Nx2 matrix')
end

ncoords = size(coords,1);

imsz = [7 90];
figsz = [30 30];

%% load RIDFs
% extract best-matching snaps and RIDFs and put into cell array (because
% the dimensions differ)
[bestsnap,bestridfs,imxi,imyi,imxyi,snx,sny,snth,p,heads]=loadridfs(shortwhd,routenum, ...
    coords,imsz,zht,snapszht,userealsnaps,improc,doautoridf,shiftridfs);

%%
if isempty(improc)
    improcstr = '';
else
    improcstr = [improc '_'];
end
flabel = g_imdb_getlabel(shortwhd);
sprows = ceil(length(snapszht)/2);
snapszhtstr = numjoin(snapszht);

if dointeractive
    if isempty(coords)
        czhti = floor(round(length(zht))/2);
        csnzhti = floor(round(length(snapszht))/2);

        selx = [];
        sely = [];
        while true % loop until user quits
            alfigure(1,dosave)
            
            % show quiver plot to click on
            g_bb_quiver(shortwhd,routenum,zht(czhti),snapszht(csnzhti), ...
                userealsnaps,false,improc,true,false,[],[],[],selx,sely);
            
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

            switch but
                case 1 % left mouse button
                    if x < 0 || x > p.lim(1) || y < 0 || y > p.lim(2)
                        disp('Invalid point selected')
                        break
                    end

                    % get nearest point on grid to click
                    [~,xi] = min(abs(p.xs-x));
                    [~,yi] = min(abs(p.ys-y));
                    selx = p.xs(xi);
                    sely = p.ys(yi);

                    plotmultiridfs(xi,yi,zht,snapszht,sprows,imxyi, ...
                        bestridfs,p,dosave,joinpdfs || isempty(coords))
                    
                    alfigure(3,dosave);clf
                    alsubplot(3,1,1,1)
                    showdiffim(xi,yi,shortwhd,czhti,csnzhti,bestsnap, ...
                        imxi,imyi,snx,sny,p)
                case 'w' % zht up
                    if czhti < length(zht)
                        czhti = czhti+1;
                    end
                case 's' % zht down
                    if czhti > 1
                        czhti = czhti-1;
                    end
                case 'q' % snapszht up
                    if csnzhti < length(snapszht)
                        csnzhti = csnzhti+1;
                    end
                case 'a' % snapszht down
                    if csnzhti > 1
                        csnzhti = csnzhti-1;
                    end
                case 'r' % reset
                    selx = [];
                    sely = [];
                case ' ' % save
                    error('todo: reimplement this')
%                     g_fig_save(sprintf('ridf_%s_%s%sres%03d_route%03d_snapszht%s_x%04d_y%04d', ...
%                         flabel,improcstr,'pm_',imsz(2),routenum,snapszhtstr,coords(i,1),coords(i,2)),figsz,figtype);
            end
        end
    else
        if length(snapszht) > 1
            error('can only have 1 snapszht')
        end
        csnapszhti = 1;
        
        figdir = fullfile('ridf_bestworst',g_imdb_getlabel(shortwhd));
        if dosave
            if pubgrade
                for i = 1:ncoords
                    ccoords = coords(i,:);
                    [xi,yi] = geticoords(ccoords,p);
                    
                    % we dump the different bits for each figure in a new dir
                    cfigdir = fullfile(figdir,sprintf('%sn%03d_%03d_%03d', ...
                        fprefix,i,xi,yi));
                    fcfigdir = fullfile(g_dir_figures,cfigdir);
                    if exist(fcfigdir,'dir')
                        if skipexisting
                            warning('figs for coords (%d,%d) already exist', ...
                                ccoords);
                            continue
                        end
                    else
                        mkdir(fcfigdir);
                    end
                    
                    % save ridfs
                    ridffigsz = [20 6];
                    clf
                    plotridfforsnap(xi,yi,csnapszhti,p,imxyi,bestridfs,zht, ...
                        snapszht,ridfx360);
                    if ridfx360
                        ridffigfn360 = fullfile(cfigdir,['ridf360.' figtype]);
                        g_fig_save(ridffigfn360,ridffigsz,figtype,figtype,[],false);

                        clf
                        plotridfforsnap(xi,yi,csnapszhti,p,imxyi,bestridfs,zht, ...
                            snapszht,false);
                    end
                    ridffigfn = fullfile(cfigdir,['ridf180.' figtype]);
                    g_fig_save(ridffigfn,ridffigsz,figtype,figtype,[],false);
                    
                    % save ridfs, using nearest snap rather than selected
                    clf
                    [rnearsnaphi,rnearsnap,nrminval,nearsnapi,nearheads, ...
                        neardiffs] = plotallnearridfs(xi,yi,snx,sny, ...
                        snth,shortwhd,zht,snapszht,csnapszhti,p, ...
                        improc,imsz,ridfx360);
                    ridfimwrite(rnearsnaphi,fullfile(g_dir_figures,cfigdir, ...
                        sprintf('nearsnap%d.png',nearsnapi)));
                    if ridfx360
                        nearridffigfn360 = fullfile(cfigdir,['nearridf360.' figtype]);
                        g_fig_save(nearridffigfn360,ridffigsz,figtype,figtype,[],false);

                        clf
                        plotallnearridfs(xi,yi,snx,sny,snth,shortwhd,zht, ...
                            snapszht,csnapszhti,p,improc,imsz,false);
                    end
                    nearridffigfn = fullfile(cfigdir,['nearridf180.' figtype]);
                    g_fig_save(nearridffigfn,ridffigsz,figtype,figtype,[],false);
                    
                    snapnums = NaN(length(zht),1);
                    for j = 1:length(zht)
                        chead = headings(i,j);
                        [snapnums(j),ridf]=plotforbestworst(xi,yi,j,csnapszhti,chead,true,false, ...
                            improc,bestridfs,bestsnap,snx,sny,snth,p,zht, ...
                            snapszht,shortwhd,imsz,imxi,imyi,heads{j,csnapszhti}, ...
                            imxyi,i,errs,allerrs,dosave,pubgrade, ...
                            cfigdir,figtype,ridfx360,rnearsnap, ...
                            rnearsnaphi,nrminval(j));
                        
                        % plot near ridfs
                        clf
                        plotnearridf(ridf,neardiffs(:,j),ridfx360)
                        if ridfx360
                            cnearridffigfn360 = fullfile(cfigdir,sprintf('z%03d_nearridf360.%s',j,figtype));
                            g_fig_save(cnearridffigfn360,ridffigsz,figtype,figtype,[],false);
                            
                            clf
                            plotnearridf(ridf,neardiffs(:,j),false)
                        end
                        cnearridffigfn = fullfile(cfigdir,sprintf('z%03d_nearridf180.%s',j,figtype));
                        g_fig_save(cnearridffigfn,ridffigsz,figtype,figtype,[],false);
                    end
                                        
                    % save details to text file
                    txtfn = fullfile(g_dir_figures,cfigdir,'details.txt');
                    fprintf('Writing %s...\n',txtfn)
                    fid = fopen(txtfn,'w');
                    fprintf(fid,'Number:         %d\n',i);
                    fprintf(fid,'Database label: %s\n',flabel);
                    fprintf(fid,'Coords:         (%d,%d)\n\n',ccoords);
                    nearsnth = snth(nearsnapi);
                    nearerrs = abs(circ_dist(nearheads,nearsnth));
                    nearerrs = min(nearerrs,pi/2);
                    nearerrs = nearerrs*180/pi;
                    for j = 1:length(zht)
                        fprintf(fid,'Height: %dmm\n',50+zht(j));
                        fprintf(fid,'  Snap num:        %d\n',snapnums(j));
                        fprintf(fid,'  Heading:         %.2fdeg\n',headings(i,j)*180/pi);
                        fprintf(fid,'  Error:           %.4fdeg\n\n',allerrs(i,j));
                        fprintf(fid,'  Snap num (near): %d\n',nearsnapi);
                        fprintf(fid,'  Heading (near):  %.2fdeg\n',nearheads(j)*180/pi);
                        fprintf(fid,'  Error (near):    %.4fdeg\n\n',nearerrs(j));
                    end
                end
                return
            end % end pubgrade
            
            if joinpdfs
                g_fig_series_start
            end
            for i = 1:ncoords
                ccoords = coords(i,:);
                [xi,yi] = geticoords(ccoords,p);
                for j = 1:length(zht)
                    figfn = fullfile(figdir,sprintf('%sn%03d_%03d_%03d_%03d', ...
                        fprefix,i,xi,yi,find(p.zs==zht(j))));
                    chead = headings(i,j);
                    plotforbestworst(xi,yi,j,csnapszhti,chead,true,false, ...
                        improc,bestridfs,bestsnap,snx,sny,snth,p,zht, ...
                        snapszht,shortwhd,imsz,imxi,imyi,heads{j,csnapszhti}, ...
                        imxyi,i,errs,allerrs,dosave,pubgrade, ...
                        [],[],ridfx360);
                    title(sprintf('Coord %d/%d',i,ncoords))
                    savebestworstfig(figdir,true,false,figfn,figtype)
                    
                    plotforbestworst(xi,yi,j,csnapszhti,chead,true,true, ...
                        improc,bestridfs,bestsnap,snx,sny,snth,p,zht, ...
                        snapszht,shortwhd,imsz,imxi,imyi,heads{j,csnapszhti}, ...
                        imxyi,i,errs,allerrs,dosave,pubgrade, ...
                        [],[],ridfx360);
                    title(sprintf('Coord %d/%d',i,ncoords))
                    savebestworstfig(figdir,true,true,figfn,figtype)
                end
            end
            pubstr = '';
            if pubgrade
                pubstr = '_pub';
            end
            if joinpdfs
                g_fig_series_end(sprintf('%spoints_@%d_%s%s.%s',fprefix, ...
                    snapszht,flabel,pubstr,figtype),[],figtype)
            end
            return
        end
        
        czhtcnt = find(zht==snapszht);
        ccoordi = 1;
        showpos = false;
        shownearest = false;
        while true
            ccoords = coords(ccoordi,:);
            [xi,yi] = geticoords(ccoords,p);
            plotforbestworst(xi,yi,czhtcnt,csnapszhti,headings(ccoordi,czhtcnt), ...
                showpos,shownearest,improc,bestridfs,bestsnap,snx,sny, ...
                snth,p,zht,snapszht,shortwhd,imsz,imxi,imyi,heads{czhtcnt,csnapszhti}, ...
                imxyi,ccoordi,errs,allerrs,dosave,pubgrade,[],[],ridfx360);
            title(sprintf('Coord %d/%d',ccoordi,ncoords))
            
            try
                [~,~,but] = ginput(1);
                if isempty(but)
                    break
                end
            catch ex
                if strcmp(ex.identifier,'MATLAB:ginput:FigureDeletionPause')
                    break
                end
            end
            
            switch but
                case 'a'
                    if ccoordi > 1
                        ccoordi = ccoordi-1;
                    end
                case {'d',1}
                    if ccoordi < ncoords
                        ccoordi = ccoordi+1;
                    end
                case 'w'
                    if czhtcnt < length(zht)
                        czhtcnt = czhtcnt+1;
                    end
                case 's'
                    if czhtcnt > 1
                        czhtcnt = czhtcnt-1;
                    end
                case 'p' % show/hide positions
                    showpos = ~showpos;
                case 'n' % show/hide nearest snap
                    shownearest = ~shownearest;
                case 'r' % reset
                    ccoordi = 1;
                case ' ' % save
                    figfn = fullfile(figdir,sprintf('%sn%03d_%03d_%03d_%03d', ...
                        fprefix,ccoordi,xi,yi,find(p.zs==zht(czhtcnt))));
                    savebestworstfig(figdir,showpos,shownearest,figfn, ...
                        figtype);
                case 27 % esc
                    close all
                    break
            end
        end
    end
else
    if joinpdfs
        g_fig_series_start
    end
    for j = 1:ncoords
        [xi,yi] = geticoords(coords(j,:),p);
        plotmultiridfs(xi,yi,zht,snapszht,sprows,imxyi,bestridfs,p, ...
            dosave,joinpdfs || isempty(coords))
        if dosave
            g_fig_save(sprintf('ridf_%s_%s%sres%03d_route%03d_snapszht%s_x%04d_y%04d', ...
                flabel,improcstr,'pm_',imsz(2),routenum,snapszhtstr,coords(j,1),coords(j,2)), ...
                figsz,figtype,[],[],joinpdfs);
        end
    end
    if joinpdfs
        g_fig_series_end(sprintf('ridf_%s_%s%sres%03d_route%03d_snapszht%s.pdf', ...
            flabel,improcstr,'pm_',imsz(2),routenum,snapszhtstr),true,figtype);
    end
end

%%
function plotmultiridfs(xi,yi,zht,snapszht,sprows,imxyi,bestridfs, ...
        p,dosave,donewfig)

gx = p.xs(xi);
gy = p.ys(yi);
fprintf('selecting point (%d,%d)\n',gx,gy)

spcols = min(2,length(snapszht));
ymax = 0;
if donewfig
    alfigure(2,dosave);clf
else
    figure
end
for cursnapszhti = 1:length(snapszht)
    subplot(sprows,spcols,cursnapszhti)
    plotridfforsnap(xi,yi,cursnapszhti,p,imxyi,bestridfs,zht,snapszht);

    yl = ylim;
    ymax = max(yl(2),ymax);
end
for cursnapszhti = 1:length(snapszht)
    subplot(sprows,spcols,cursnapszhti)
    ylim([0 ymax])
end

%%
function showdiffim(xi,yi,shortwhd,czhti,csnzhti,bestsnap,imxi,imyi,snx,sny,p)
warning('snapshots are broken in this function (wrong zi)')

% get the image for the clicked position
im = g_imdb_getim(shortwhd,xi,yi,czhti);

% get best-matching snap for this position
snapi = bestsnap{czhti,csnzhti};
possel = imxi==xi & imyi==yi;
csnapi = snapi(possel);
[snxi,snyi] = geticoords([snx(csnapi), sny(csnapi)],p);
snap = g_imdb_getim(shortwhd,snxi,snyi,csnzhti);

imshow(im)
title(sprintf('current view (%d,%d)',p.xs(xi),p.ys(yi)))

alsubplot(2,1)
imshow(snap)
title(sprintf('best-matching snapshot (#%d)',csnapi))

alsubplot(3,1)
imagesc(im2double(im)-im2double(snap))
title('difference')
axis equal tight
colorbar

%%
function [xi,yi]=geticoords(coords,p)
xi = find(p.xs==coords(1));
yi = find(p.ys==coords(2));
if isempty(xi) || isempty(yi)
    error('could not find coords (%d,%d)',coords);
end 

%%
function diffs=plotridfforsnap(xi,yi,csnapszhti,p,imxyi,bestridfs,zht, ...
snapszht,ridfx360,head)

if nargin < 9
    ridfx360 = false;
end
if nargin < 10
    head = [];
end

diffs = getridfs(xi,yi,csnapszhti,bestridfs,imxyi,zht);
ttl = sprintf('(%d, %d) Training height: %d mm',p.xs(xi),p.ys(yi), ...
    snapszht(csnapszhti)+50);
plotridf(diffs,zht,snapszht,ridfx360,csnapszhti,ttl,head)

%%
function plotridf(diffs,zht,snapszht,ridfx360,csnapszhti,ttl,head)
if nargin < 7
    head = [];
end
if nargin < 6
    ttl = [];
end
if nargin < 5
    csnapszhti = [];
end
if nargin < 4
    ridfx360 = false;
end

if ridfx360
    xlo = 0; xhi = 360;
else
    xlo = -180; xhi = 180;
    diffs = circshift(diffs,floor(size(diffs,1)/2));
end

diffs(end+1,:) = diffs(1,:);
ths = repmat(linspace(xlo,xhi,size(diffs,1))',1,size(diffs,2));
h=plot(ths,diffs);

if ~isempty(csnapszhti)
    refzi = zht==snapszht(csnapszhti);
    h(refzi).LineStyle='--';
end

xlim([xlo xhi])
set(gca,'XTick',xlo:90:xhi)
xlabel('Angle (deg)')
if ~isempty(ttl)
    title(ttl)
end
hl = legend(num2str((zht+50)')); %,'Location','BestOutside');
title(hl,'Height (mm)')

g_fig_setfont
andy_setbox

if ~isempty(head)
    % plot vertical line indicating estimated heading
    hold on
    phead = mod(head*180/pi,360);
    if ~ridfx360 && phead > 180
        phead = phead-360;
    end
    pl=line([phead phead],ylim,'Color','k','LineStyle',':');
    leginf = get(get(pl,'Annotation'),'LegendInformation');
    set(leginf,'IconDisplayStyle','off')
    axis tight
end

%%
function plotnearridf(ridf,nearridf,ridfx360) %,head)
diffs = [ridf nearridf];

if ridfx360
    xlo = 0; xhi = 360;
else
    xlo = -180; xhi = 180;
    diffs = circshift(diffs,floor(size(diffs,1)/2));
end

diffs(end+1,:) = diffs(1,:);
ths = repmat(linspace(xlo,xhi,size(diffs,1))',1,size(diffs,2));
plot(ths,diffs);

xlim([xlo xhi])
set(gca,'XTick',xlo:90:xhi)
xlabel('Angle (deg)')
legend('Selected snapshot','Nearest snapshot'); %,'Location','BestOutside');

g_fig_setfont
andy_setbox

%%
function [rsnaphi,rsnap,minval,nearsnapi,nearheads,neardiffs]=plotallnearridfs(xi,yi,snx,sny,snth,shortwhd,zht,snapszht, ...
    csnapszhti,p,improc,imsz,ridfx360)
	
% nearest snap (Euclidean distance)
imfun = gantry_getimfun(improc);
ims = NaN([imsz,length(zht)]);
for i = 1:length(zht)
    ims(:,:,i) = g_imdb_getprocim(shortwhd,xi,yi,find(p.zs==zht(i)), ...
        imfun,imsz(2));
end

[~,nearsnapi] = min(hypot(sny-p.ys(yi),snx-p.xs(xi)));
[snxi,snyi] = geticoords([snx(nearsnapi),sny(nearsnapi)],p);
snzi = find(p.zs==snapszht(csnapszhti));

[snap,snaphi] = g_imdb_getprocim(shortwhd,snxi,snyi,snzi,imfun,imsz(2));
nearsnth = snth(nearsnapi);
rsnap = rotim(snap,nearsnth);
if nargout
    rsnaphi = rotim(snaphi,snth(nearsnapi));
end

neardiffs = NaN(imsz(2),length(zht));
[nearheads,minval] = deal(NaN(length(zht),1));
for i = 1:length(zht)
    [nearheads(i),minval(i),~,neardiffs(:,i)] = ridfheadmulti(ims(:,:,i),rsnap);
end
neardiffs = neardiffs / prod(imsz);
minval = minval / prod(imsz);

plotridf(neardiffs,zht,snapszht,ridfx360,csnapszhti);

%%
function savebestworstfig(figdir,showpos,shownearest,figfn,figtype)
cfigdir = fullfile(g_dir_figures,figdir);
if ~exist(cfigdir,'dir')
    mkdir(cfigdir)
end

if shownearest
    figfn = [figfn '_nearest'];
end
figfn = [figfn '.' figtype];
g_fig_save(figfn,[(showpos+1)*15 15],figtype,figtype,[],false);

%%
function [csnapi,ridf]=plotforbestworst(xi,yi,czhti,csnapszhti,head,showpos, ...
    shownearest,improc,bestridfs,bestsnap,snx,sny,snth,p,zht,snapszht, ...
    shortwhd,imsz,imxi,imyi,allheads,imxyi,ccoordi,errs,allerrs,dosave, ...
    pubgrade,cfigdir,figtype,ridfx360,rnearsnap,rnearsnaphi,nrminval)

if pubgrade && shownearest
    error('pubgrade and shownearest can''t both be true')
end

% make colormap
up = linspace(0,1,32)';
down = up(end:-1:1);
redblue = [up,up,ones(32,1);ones(32,1),down,down];

imfun = gantry_getimfun(improc);

[zhti,~] = find(bsxfun(@eq,p.zs',zht));
zi = zhti(czhti);
[im,imhi] = g_imdb_getprocim(shortwhd,xi,yi,zi,imfun,imsz(2));

% nearest snap (Euclidean distance)
[~,nearsnapi] = min(hypot(sny-p.ys(yi),snx-p.xs(xi)));
snapi = bestsnap{czhti,csnapszhti};
chosensnapi = snapi(imxi==xi & imyi==yi);
if shownearest
    csnapi = nearsnapi;
else
    csnapi = chosensnapi;
end
csnx = snx(csnapi);
csny = sny(csnapi);
[snxi,snyi] = geticoords([csnx,csny],p);
snzi = find(p.zs==snapszht(csnapszhti));
[snap,snaphi] = g_imdb_getprocim(shortwhd,snxi,snyi,snzi,imfun,imsz(2));
rsnaphi = rotim(snaphi,snth(csnapi));
rsnap = rotim(snap,snth(csnapi));

alfigure(1,dosave);clf
if ~pubgrade
    alsubplot(5,1+showpos,1:2,[1 1+showpos])
end
if shownearest
    [head,minval,~,ridf] = ridfheadmulti(im,rsnap);
    if ~ridfx360
        ridf = circshift(ridf,floor(imsz(2)/2));
    end
    ridf = ridf / prod(imsz);
    ridf(end+1) = ridf(1);
    if ridfx360
        xlo = 0; xhi = 360;
    else
        xlo = -180; xhi = 180;
    end
    plot(linspace(xlo,xhi,imsz(2)+1),ridf)
    set(gca,'XTick',xlo:90:xhi)
    xlim([xlo xhi]);
    minval = minval / prod(imsz);
else
    if pubgrade
        cridfs = getridfs(xi,yi,csnapszhti,bestridfs,imxyi,zht);
    else
        cridfs = plotridfforsnap(xi,yi,csnapszhti,p,imxyi,bestridfs,zht, ...
            snapszht,ridfx360,head);
    end
    minval = min(cridfs(:,czhti));
    ridf = cridfs(:,czhti);
end

% get correctly rotated versions of im and snap
rimhi = rotim(imhi,head);
rim = rotim(im,head);

% calculate difference image
diffimlo = im2double(rim)-im2double(rsnap);
minval2 = mean2(abs(diffimlo));
diffval = minval2-minval;
if abs(diffval) >= 1e-5 % check that the difference value is correct
    error('assertion failed (coord: %d; nearest: %d; zht: %.2f; diff: %g)', ...
        ccoordi,shownearest,zht(czhti)+50,diffval)
end

if pubgrade
    fpref = sprintf('z%03d',zi);
    ffigdir = fullfile(g_dir_figures,cfigdir);

    % save quiver
    clf
    bestworstquiver(p,imxi,imyi,allheads,snx,sny,xi,yi,nearsnapi, ...
        chosensnapi);
    quiverfigfn = fullfile(cfigdir,[fpref '_quiver.' figtype]);
    g_fig_save(quiverfigfn,[15 10],figtype,figtype,[],false);

    % save "current" view
    ridfimwrite(imhi,fullfile(ffigdir,[fpref '_unrotim.png']));
    ridfimwrite(rimhi,fullfile(ffigdir,[fpref '_im.png']));

    % save best-matching snapshot
    ridfimwrite(rsnaphi,fullfile(ffigdir, ...
        sprintf('%s_snap%d.png',fpref,csnapi)));

    % save difference images (at best-matching rotation)
    diffimhi = im2double(rimhi)-im2double(rsnaphi);
    diffimwrite(diffimhi,redblue, ...
        fullfile(ffigdir,[fpref '_diffhi.png']));
    diffimwrite(diffimlo,redblue, ...
        fullfile(ffigdir,[fpref '_diff.png']));

    % for "nearest" snap
    nrhead = ridfheadmulti(im,rnearsnap);
    nrimhi = rotim(imhi,nrhead);
    ridfimwrite(nrimhi,fullfile(ffigdir,[fpref '_nearim.png']));

    nrdiffimhi = im2double(nrimhi)-im2double(rnearsnaphi);
    diffimwrite(nrdiffimhi,redblue, ...
        fullfile(ffigdir,[fpref '_diffnearhi.png']));

    nrim = rotim(im,nrhead);
    nrdiffim = im2double(nrim)-im2double(rnearsnap);
    nrminval2 = mean2(abs(nrdiffim));
    nrdiffval = nrminval2-nrminval;
    if abs(nrdiffval) >= 1e-5
        error('assertion failed (nearest; coord: %d; nearest: %d; zht: %.2f; diff: %g)', ...
            ccoordi,shownearest,zht(czhti)+50,diffval)
    end
    diffimwrite(nrdiffim,redblue,...
        fullfile(ffigdir,[fpref '_diffnear.png']));

    return
end % end pubgrade

alsubplot(3,1)
imshow(rimhi)
title(sprintf('Test height: %dmm; err: %.2fdeg; overall err: %.2fdeg', ...
    zht(czhti)+50,allerrs(ccoordi,czhti),errs(ccoordi)))

alsubplot(4,1)
imshow(rsnaphi)
dist = hypot(p.ys(yi)-csny,p.xs(xi)-csnx);
if shownearest
    h=title(sprintf('Nearest snap num: %d @%gmm',csnapi,dist));
else
    h=title(sprintf('Snap num: %d @%gmm',csnapi,dist));
end
if csnapi==nearsnapi
    set(h,'Color','b');
end

ax=alsubplot(5,1);
imagesc(diffimlo)
pxdiff = minval*prod(imsz);
title(sprintf('min diff: %.3f (=%.2fpx)',minval,pxdiff))
caxis([-1 1])
colormap(ax,redblue)
axis equal tight off

if showpos
    alsubplot(3:5,2)
    bestworstquiver(p,imxi,imyi,allheads,snx,sny,xi,yi,nearsnapi, ...
        chosensnapi);
end

%%
function bestworstquiver(p,imxi,imyi,heads,snx,sny,xi,yi,nearsnapi, ...
    chosensnapi)

hold on
imx = p.xs(imxi);
imy = p.ys(imyi);
anglequiver(imx,imy,heads)
selsn = any(bsxfun(@eq,snx,imx) & bsxfun(@eq,sny,imy));
snheads = heads(selsn);
anglequiver(imx(selsn),imy(selsn),snheads,[],'g')
axis equal tight
plot(p.xs(xi),p.ys(yi),'kd', ...
    snx(nearsnapi),sny(nearsnapi),'ko', ...
    snx(chosensnapi),sny(chosensnapi),'ro', ...
    'MarkerSize',8,'LineWidth',2)

%%
function alfigure(num,dosave)
if ~dosave || ~isgraphics(num)
    figure(num)
else
    set(0,'CurrentFigure',num);
end

%%
function cridfs=getridfs(xi,yi,csnapszhti,bestridfs,imxyi,zht)
% get RIDF for best match
cridfs = NaN(size(bestridfs{1},2),length(zht));
for i = 1:length(zht)
    cind = find(all(bsxfun(@eq,imxyi{i,csnapszhti},[xi yi]),2),1);
    if isempty(cind)
        warning('no match found')
        return
    end

    cridfs(:,i) = bestridfs{i,csnapszhti}(cind,:);
end

%%
function ridfimwrite(im,varargin)
fprintf('Saving image to %s...\n',varargin{end});
imwrite(im,varargin{:});

%%
function diffimwrite(diffim,redblue,fpath)
ridfimwrite(round(1+(size(redblue,1)-1)*(diffim+1)/2),redblue,fpath);

%%
function rim=rotim(im,th)
rim = circshift(im,round(th*size(im,2)/(2*pi)),2);

%%
function [bestsnap,bestridfs,imxi,imyi,imxyi,snx,sny,snth,p,allheads]=loadridfs(shortwhd,routenum,coords, ...
    imsz,zht,snapszht,userealsnaps,improc,doautoridf,shiftridfs)

if shiftridfs
    % see code below
    warning('the shiftridfs code may be dubious...')
end

forcegen = false;

[bestsnap,bestridfs,imxyi,allheads] = deal(cell(length(zht),length(snapszht)));
for i = 1:length(zht)
    for j = 1:length(snapszht)
        [imxi,imyi,heads,whsn,~,~,~,snx,sny,snth,~,p,~,~,ridfs] = g_imdb_route_getdata( ...
            shortwhd,routenum,imsz(2),zht(i),false,improc,forcegen,[], ...
            userealsnaps,snapszht(j));
        
        allheads{i,j} = heads;

        if doautoridf
            [ind,sni] = deal(NaN(ncoords,1));
            icoords = NaN(size(coords));
            for k = 1:ncoords
                sni(k) = find(snx==coords(k,1) & sny==coords(k,2));
                icoords(k,:) = [find(coords(k,1)==p.xs), find(coords(k,2)==p.ys)];
                ind(k) = find(icoords(k,1)==imxi & icoords(k,2)==imyi);
            end
            whsn = sni;
            imxyi{i,j} = icoords;
        else
            ind = 1:length(whsn);
            imxyi{i,j} = [imxi, imyi];
        end
        bestsnap{i,j} = whsn;
        
        bestridfs{i,j} = NaN(length(whsn),imsz(2));
        for k = 1:length(ind)
            % RIDFs will be shifted by snth(whsn(k)); centre on 0? instead
            if shiftridfs
                % double-check this code
                cridf = rotim(ridfs(ind(k),:,whsn(k)),-snth(whsn(k)));
            else
                cridf = ridfs(ind(k),:,whsn(k));
            end
            bestridfs{i,j}(k,:) = cridf / prod(imsz);
        end
    end
end
