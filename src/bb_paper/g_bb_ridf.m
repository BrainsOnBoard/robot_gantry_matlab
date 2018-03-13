function g_bb_ridf(shortwhd,routenum,zht,snapszht,userealsnaps,improc, ...
    coords,shiftridfs,dosave,joinpdfs,figtype,doautoridf,dointeractive, ...
    headings,errs,allerrs,fprefix,pubgrade,ridfx360)
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
if nargin < 10 || isempty(joinpdfs)
    joinpdfs = false;
end
if nargin < 11 || isempty(figtype)
    figtype = 'pdf';
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

if userealsnaps && length(snapszht) > 1
    % this may change...
    error('cannot have real snapshots and multiple snapszht')
end

forcegen = false;
ncoords = size(coords,1);

imsz = [7 90];
figsz = [30 30];

%% load RIDFs
% extract best-matching snaps and RIDFs and put into cell array (because
% the dimensions differ)
[bestsnap,bestridfs,imxyi] = deal(cell(length(zht),length(snapszht)));
for i = 1:length(zht)
    for j = 1:length(snapszht)
        [imxi,imyi,allheads,whsn,~,~,~,snx,sny,snth,~,p,~,~,ridfs] = g_imdb_route_getdata( ...
            shortwhd,routenum,imsz(2),zht(i),false,improc,forcegen,[], ...
            userealsnaps,snapszht(j));

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
                cridf = circshift(ridfs(ind(k),:,whsn(k)),-round(snth(whsn(k)) * size(ridfs,2) / (2*pi)),2);
            else
                cridf = ridfs(ind(k),:,whsn(k));
            end
            bestridfs{i,j}(k,:) = cridf / prod(imsz);
        end
    end
end

%%
% imfun = gantry_getimfun(improc);
% if userealsnaps
%     [snaps,~,snx,sny]=g_imdb_route_getrealsnaps(p.arenafn,routenum,imsz(2),imfun);
% else
%     [snaps,snx,sny]=g_imdb_route_getimdbsnaps(p.arenafn,routenum,imsz(2),imfun,shortwhd,find(p.zs==snapszht),p.imsep);
% end

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

        % show quiver plot to click on
        showquiver

        while true % loop until user quits
            alfigure(1,dosave)
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

                    plotmultiridfs(xi,yi)
                    
                    alfigure(3,dosave);clf
                    alsubplot(3,1,1,1)
                    showdiffim(xi,yi)
                case 'w' % zht up
                    if czhti < length(zht)
                        czhti = czhti+1;
                        showquiver
                    end
                case 's' % zht down
                    if czhti > 1
                        czhti = czhti-1;
                        showquiver
                    end
                case 'q' % snapszht up
                    if csnzhti < length(snapszht)
                        csnzhti = csnzhti+1;
                        showquiver
                    end
                case 'a' % snapszht down
                    if csnzhti > 1
                        csnzhti = csnzhti-1;
                        showquiver
                    end
                case ' ' % save
                    g_fig_save(sprintf('ridf_%s_%s%sres%03d_route%03d_snapszht%s_x%04d_y%04d', ...
                        flabel,improcstr,'pm_',imsz(2),routenum,snapszhtstr,coords(i,1),coords(i,2)),figsz,figtype);
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
                for ccoordi = 1:ncoords
                    for czhtcnt = 1:length(zht)
                        ccoords = coords(ccoordi,:);
                        chead = headings(ccoordi,czhtcnt);
                        xi = find(p.xs==ccoords(1));
                        yi = find(p.ys==ccoords(2));
                        
                        % we dump the different bits for each figure in a
                        % new dir
                        cfigdir = fullfile(figdir,sprintf('%sn%03d_%03d_%03d', ...
                            fprefix,ccoordi,xi,yi));
                        fcfigdir = fullfile(g_dir_figures,cfigdir);
                        if ~exist(fcfigdir,'dir')
                            mkdir(fcfigdir);
                        end
                        
                        plotforbestworst(xi,yi,czhtcnt,csnapszhti,chead,true,false, ...
                            improc,bestridfs,bestsnap,snx,sny,snth,p,zht, ...
                            snapszht,shortwhd,imsz,imxi,imyi,allheads, ...
                            imxyi,ccoordi,errs,allerrs,dosave,pubgrade, ...
                            cfigdir,figtype,ridfx360)
                    end
                end
                return
            end
            
            if joinpdfs
                g_fig_series_start
            end
            for ccoordi = 1:ncoords
                for czhtcnt = 1:length(zht)
                    ccoords = coords(ccoordi,:);
                    chead = headings(ccoordi,czhtcnt);
                    xi = find(p.xs==ccoords(1));
                    yi = find(p.ys==ccoords(2));
                    plotforbestworst(xi,yi,czhtcnt,csnapszhti,chead,true,false, ...
                        improc,bestridfs,bestsnap,snx,sny,snth,p,zht, ...
                        snapszht,shortwhd,imsz,imxi,imyi,allheads, ...
                        imxyi,ccoordi,errs,allerrs,dosave,pubgrade, ...
                        [],[],ridfx360)
                    title(sprintf('Coord %d/%d',ccoordi,ncoords))
                    savebestworstfig(figdir,true,false,getfigfn, ...
                        figtype)
                    
                    plotforbestworst(xi,yi,czhtcnt,csnapszhti,chead,true,true, ...
                        improc,bestridfs,bestsnap,snx,sny,snth,p,zht, ...
                        snapszht,shortwhd,imsz,imxi,imyi,allheads, ...
                        imxyi,ccoordi,errs,allerrs,dosave,pubgrade, ...
                        [],[],ridfx360)
                    title(sprintf('Coord %d/%d',ccoordi,ncoords))
                    savebestworstfig(figdir,true,true,getfigfn, ...
                        figtype)
                end
            end
            pubstr = '';
            if pubgrade
                pubstr = '_pub';
            end
            if joinpdfs
                g_fig_series_end(sprintf('%spoints_@%d_%s%s.%s',fprefix, ...
                    snapszht,shortwhd,pubstr,figtype),[],figtype)
            end
            return
        end
        
        czhtcnt = find(zht==snapszht);
        ccoordi = 1;
        showpos = false;
        shownearest = false;
        while true
            ccoords = coords(ccoordi,:);
            xi = find(p.xs==ccoords(1));
            yi = find(p.ys==ccoords(2));
            plotforbestworst(xi,yi,czhtcnt,csnapszhti,headings(ccoordi,czhtcnt), ...
                showpos,shownearest,improc,bestridfs,bestsnap,snx,sny, ...
                snth,p,zht,snapszht,shortwhd,imsz,imxi,imyi,allheads, ...
                imxyi,ccoordi,errs,allerrs,dosave,pubgrade,[],[],ridfx360)
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
                    savebestworstfig(figdir,showpos,shownearest, ...
                        getfigfn,figtype);
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
    for i = 1:ncoords
        % get corresponding grid coords
        xi = find(p.xs==coords(i,1));
        yi = find(p.ys==coords(i,2));
        
        plotmultiridfs(xi,yi)
        if dosave
            g_fig_save(sprintf('ridf_%s_%s%sres%03d_route%03d_snapszht%s_x%04d_y%04d', ...
                flabel,improcstr,'pm_',imsz(2),routenum,snapszhtstr,coords(i,1),coords(i,2)), ...
                figsz,figtype,[],[],joinpdfs);
        end
    end
    if joinpdfs
        g_fig_series_end(sprintf('ridf_%s_%s%sres%03d_route%03d_snapszht%s.pdf', ...
            flabel,improcstr,'pm_',imsz(2),routenum,snapszhtstr),true,figtype);
    end
end

    function showquiver
        g_bb_quiver(shortwhd,routenum,zht(czhti),snapszht(csnzhti), ...
            userealsnaps,false,improc,true,false);
    end

    function figfn=getfigfn
        figfn = fullfile(figdir,sprintf('%sn%03d_%03d_%03d_%03d', ...
            fprefix,ccoordi,xi,yi,find(p.zs==zht(czhtcnt))));
    end
    
    function plotmultiridfs(xi,yi)
        gx = p.xs(xi);
        gy = p.ys(yi);
        fprintf('selecting point (%d,%d)\n',gx,gy)
        
        spcols = min(2,length(snapszht));
        ymax = 0;
        if joinpdfs || isempty(coords)
            alfigure(2,dosave);clf
        else
            figure
        end
        for csnapszhti = 1:length(snapszht)
            subplot(sprows,spcols,csnapszhti)
            plotridf(xi,yi,csnapszhti,p,imxyi,bestridfs,zht,snapszht);
            
            yl = ylim;
            ymax = max(yl(2),ymax);
        end
        for csnapszhti = 1:length(snapszht)
            subplot(sprows,spcols,csnapszhti)
            ylim([0 ymax])
        end
    end

    function showdiffim(xi,yi)
        warning('snapshots are broken in this function (wrong zi)')
        
        % get the image for the clicked position
        im = g_imdb_getim(shortwhd,xi,yi,czhti);
        
        % get best-matching snap for this position
        snapi = bestsnap{czhti,csnzhti};
        posi = find(imxi==xi & imyi==yi);
        snxi = find(p.xs==snx(snapi(posi)));
        snyi = find(p.ys==sny(snapi(posi)));
        snap = g_imdb_getim(shortwhd,snxi,snyi,csnzhti);
        
        imshow(im)
        title('current view')
        
        alsubplot(2,1)
        imshow(snap)
        title('best-matching snapshot')
        
        alsubplot(3,1)
        imagesc(im2double(im)-im2double(snap))
        title('difference')
        axis equal tight
        colorbar
    end
end

function minval=plotridf(xi,yi,csnapszhti,czhti,p,imxyi,bestridfs,zht, ...
    snapszht,ridfx360)

    if nargin < 10
        ridfx360 = false;
    end

    gx = p.xs(xi);
    gy = p.ys(yi);

    % get RIDF for best match
    cridfs = NaN(size(bestridfs{1},2),length(zht));
%         snaps = NaN(length(zht),1);
    for besti = 1:length(zht)
        cind = find(all(bsxfun(@eq,imxyi{besti,csnapszhti},[xi yi]),2),1);
        if isempty(cind)
            warning('no match found')
            return
        end

        cridfs(:,besti) = bestridfs{besti,csnapszhti}(cind,:);
%             snaps(besti) = bestsnap{besti,csnapszhti}(cind);
%             fprintf('best snap: %d\n',bestsnap{besti,csnapszhti}(cind));
    end

    if ridfx360
        xlo = 0; xhi = 360;
    else
        xlo = -180; xhi = 180;
    end
    ths = repmat(linspace(xlo,xhi,size(cridfs,1)+1)',1,size(cridfs,2));
    if ~ridfx360
        cridfs = circshift(cridfs,floor(size(cridfs,1)/2));
    end
    cridfs(end+1,:) = cridfs(1,:);

    h=plot(ths,cridfs);
    
    refzi = zht==snapszht(csnapszhti);
    h(refzi).LineStyle='--';
    xlim([xlo xhi])
    set(gca,'XTick',xlo:90:xhi)
    xlabel('Angle (deg)')
    title(sprintf('(%d, %d) Training height: %d mm',gx,gy,snapszht(csnapszhti)+50))
    hl = legend(num2str((zht+50)')); %,'Location','BestOutside');
    title(hl,'Height (mm)')

    g_fig_setfont
    andy_setbox

    minval = min(cridfs(:,czhti));
end

function savebestworstfig(figdir,showpos,shownearest,figfn,figtype)
    if ~exist(['figures/' figdir],'dir')
        mkdir(['figures/' figdir])
    end
    
    if shownearest
        figfn = [figfn '_nearest'];
    end
    figfn = [figfn '.' figtype];
    g_fig_save(figfn,[(showpos+1)*15 15],figtype,figtype,[],false);
end

function plotforbestworst(xi,yi,czhti,csnapszhti,head,showpos, ...
    shownearest,improc,bestridfs,bestsnap,snx,sny,snth,p,zht,snapszht, ...
    shortwhd,imsz,imxi,imyi,allheads,imxyi,ccoordi,errs,allerrs,dosave, ...
    pubgrade,cfigdir,figtype,ridfx360)

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
    snxi = find(p.xs==csnx);
    snyi = find(p.ys==csny);
    snzi = find(p.zs==snapszht(csnapszhti));
    [snap,snaphi] = g_imdb_getprocim(shortwhd,snxi,snyi,snzi,imfun,imsz(2));
    rsnaphi = circshift(snaphi,round(snth(csnapi)*size(snaphi,2)/(2*pi)),2);
    rsnap = circshift(snap,round(snth(csnapi)*imsz(2)/(2*pi)),2);

    alfigure(1,dosave);clf
    if ~pubgrade
        alsubplot(5,1+showpos,1:2,[1 1+showpos])
    end
    if shownearest
        [head,minval,~,diffs] = ridfheadmulti(im,rsnap);
        if ~ridfx360
            diffs = circshift(diffs,floor(imsz(2)/2));
        end
        diffs = diffs / prod(imsz);
        diffs(end+1) = diffs(1);
        if ridfx360
            xlo = 0; xhi = 360;
        else
            xlo = -180; xhi = 180;
        end
        plot(linspace(xlo,xhi,imsz(2)+1),diffs)
        set(gca,'XTick',xlo:90:xhi)
        xlim([xlo xhi]);
        minval = minval / prod(imsz);
    else
        minval = plotridf(xi,yi,csnapszhti,czhti,p,imxyi,bestridfs,zht, ...
            snapszht,ridfx360);
    end
    
    % plot vertical line indicating estimated heading
    hold on
    phead = mod(head*180/pi,360);
    if ~ridfx360 && phead > 180
        phead = phead-360;
    end
    line([phead phead],ylim,'Color','k','LineStyle',':');
    axis tight
    
    % get correctly rotated versions of im and snap
    rimhi = circshift(imhi,round(head*size(imhi,2)/(2*pi)),2);
    rim = circshift(im,round(head*imsz(2)/(2*pi)),2);
    
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
        
        % save ridf
        if ridfx360
            ridffigfn360 = fullfile(cfigdir,[fpref '_ridf360.' figtype]);
            g_fig_save(ridffigfn360,[15 7],figtype,figtype,[],false);
            
            clf
            plotridf(xi,yi,csnapszhti,czhti,p,imxyi,bestridfs,zht, ...
                snapszht,false);
        end
        ridffigfn = fullfile(cfigdir,[fpref '_ridf180.' figtype]);
        g_fig_save(ridffigfn,[15 7],figtype,figtype,[],false);
        
        % save quiver
        clf
        bestworstquiver(p,imxi,imyi,allheads,snx,sny,xi,yi,nearsnapi, ...
            chosensnapi);
        quiverfigfn = fullfile(cfigdir,[fpref '_quiver.' figtype]);
        g_fig_save(quiverfigfn,[15 10],figtype,figtype,[],false);
        
        % save "current" view
        imwrite(rimhi,fullfile('figures',cfigdir,[fpref '_im.png']));
        
        % save best-matching snapshot
        imwrite(rsnaphi,fullfile('figures',cfigdir,[fpref '_snap.png']));
        
        % save difference images (at best-matching rotation)
        diffimhi = im2double(rimhi)-im2double(rsnaphi);
        imwrite(round(1+(size(redblue,1)-1)*(diffimhi+1)/2),redblue, ...
            fullfile('figures',cfigdir,[fpref '_diffhi.png']));
        imwrite(round(1+(size(redblue,1)-1)*(diffimlo+1)/2),redblue, ...
            fullfile('figures',cfigdir,[fpref '_diff.png']));
        
        return
    end

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
end

function bestworstquiver(p,imxi,imyi,allheads,snx,sny,xi,yi,nearsnapi, ...
    chosensnapi)

    hold on
    imx = p.xs(imxi);
    imy = p.ys(imyi);
    anglequiver(imx,imy,allheads)
    snheads = allheads(any(bsxfun(@eq,snx,imx) & bsxfun(@eq,sny,imy)));
    anglequiver(snx,sny,snheads,[],'g')
    axis equal tight
    plot(p.xs(xi),p.ys(yi),'kd', ...
        snx(nearsnapi),sny(nearsnapi),'ko', ...
        snx(chosensnapi),sny(chosensnapi),'ro', ...
        'MarkerSize',8,'LineWidth',2)
end

function alfigure(num,dosave)
    if ~dosave || ~isgraphics(num)
        figure(num)
    else
        set(0,'CurrentFigure',num);
    end
end
