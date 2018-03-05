function g_bb_ridf(shortwhd,routenum,zht,snapszht,userealsnaps,improc, ...
    coords,shiftridfs,dosave,joinpdfs,figtype,doautoridf,dointeractive, ...
    headings,errs,allerrs)
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

if userealsnaps && length(snapszht) > 1
    % this may change...
    error('cannot have real snapshots and multiple snapszht')
end

forcegen = false;

imsz = [7 90];
% whd = fullfile(g_dir_imdb,shortwhd);

figsz = [30 30];

%% load RIDFs
% extract best-matching snaps and RIDFs and put into cell array (because
% the dimensions differ)
[bestsnap,bestridfs,imxyi] = deal(cell(length(zht),length(snapszht)));
for i = 1:length(zht)
    for j = 1:length(snapszht)
        [imxi,imyi,~,whsn,~,~,~,snx,sny,snth,~,p,~,~,ridfs] = g_imdb_route_getdata( ...
            shortwhd,routenum,imsz(2),zht(i),false,improc,forcegen,[], ...
            userealsnaps,snapszht(j));

        if doautoridf
            [ind,sni] = deal(NaN(size(coords,1),1));
            icoords = NaN(size(coords));
            for k = 1:size(coords,1)
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
flabel = g_imdb_getlabel(fullfile(g_dir_imdb,shortwhd));
sprows = ceil(length(snapszht)/2);
snapszhtstr = numjoin(snapszht);

if dointeractive
    if isempty(coords)
        czhti = floor(round(length(zht))/2);
        csnzhti = floor(round(length(snapszht))/2);

        % show quiver plot to click on
        showquiver

        while true % loop until user quits
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
                    
                    figure(3);clf
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
        
        czhtcnt = find(zht==snapszht);
        ccoordi = 1;
        while true
            xi = find(p.xs==coords(ccoordi,1));
            yi = find(p.ys==coords(ccoordi,2));
            plotforbestworst(xi,yi,czhtcnt,headings(ccoordi,czhtcnt))
            title(sprintf('Coord %d/%d',ccoordi,size(coords,1)))
            
            try
                [~,~,but] = ginput(1);
                if isempty(but)
                    break
                end
                
                switch but
                    case 'a'
                        if ccoordi > 1
                            ccoordi = ccoordi-1;
                        end
                    case {'d',1}
                        if ccoordi < size(coords,1)
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
                    case 'r' % reset
                        ccoordi = 1;
                end
            catch ex
                if strcmp(ex.identifier,'MATLAB:ginput:FigureDeletionPause')
                    break
                end
            end
        end
    end
else
    if joinpdfs
        g_fig_series_start
    end
    for i = 1:size(coords,1)
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

    function plotforbestworst(xi,yi,zhtcnt,head)
        csnzhti = 1;
        imfun = gantry_getimfun(improc);
        
        [zhti,~] = find(bsxfun(@eq,p.zs',zht));
        whd = fullfile(g_dir_imdb,shortwhd);
        
        figure(1);clf
        alsubplot(4,1,1,1)
        plotridf(xi,yi,csnzhti)
        
        alsubplot(2,1)
        [im,rawim] = g_imdb_getprocim(whd,xi,yi,zhti(zhtcnt),imfun,imsz(2));
        rrawim = circshift(rawim,round(head*size(rawim,2)/(2*pi)),2);
        imshow(rrawim)
        title(sprintf('Test height: %dmm; err: %.2fdeg; mean err: %.2fdeg', ...
            zht(zhtcnt)+50,allerrs(ccoordi,zhtcnt),errs(ccoordi)))

        alsubplot(3,1)
        snapi = bestsnap{zhtcnt,csnzhti};
        csnapi = snapi(imxi==xi & imyi==yi);
        csnx = snx(csnapi);
        csny = sny(csnapi);
        snxi = find(p.xs==csnx);
        snyi = find(p.ys==csny);
        snzi = find(p.zs==snapszht(csnzhti));
        [snap,rawsnap] = g_imdb_getprocim(whd,snxi,snyi,snzi,imfun,imsz(2));
        rrawsnap = circshift(rawsnap,round(head*size(rawsnap,2)/(2*pi)),2);
        imshow(rrawsnap)
        dist = hypot(p.ys(yi)-csny,p.xs(xi)-csnx);
        title(sprintf('Snap num: %d @%gmm',csnapi,dist))
        
%         csnth = snth(csnapi);
%         snrot = round(csnth*imsz(2)/(2*pi));
%         rotsnap = circshift(snap,snrot,2);
        
        alsubplot(4,1)
        imagesc(im2double(rrawim)-im2double(rrawsnap))
        axis equal tight
        colorbar
    end
    
    function plotmultiridfs(xi,yi)
        gx = p.xs(xi);
        gy = p.ys(yi);
        fprintf('selecting point (%d,%d)\n',gx,gy)
        
        spcols = min(2,length(snapszht));
        ymax = 0;
        if joinpdfs || isempty(coords)
            figure(2);clf
        else
            figure
        end
        for csnapszhti = 1:length(snapszht)
            subplot(sprows,spcols,csnapszhti)
            plotridf(xi,yi,csnapszhti)
            
            yl = ylim;
            ymax = max(yl(2),ymax);
        end
        for csnapszhti = 1:length(snapszht)
            subplot(sprows,spcols,csnapszhti)
            ylim([0 ymax])
        end
    end

    function plotridf(xi,yi,csnapszhti)
        gx = p.xs(xi);
        gy = p.ys(yi);
        
        % get RIDF for best match
        cridfs = NaN(imsz(2),length(zht));
%         snaps = NaN(length(zht),1);
        if doautoridf % why are these two bits identical?
            for besti = 1:length(zht)
                cind = find(all(bsxfun(@eq,imxyi{besti,csnapszhti},[xi yi]),2),1);
                if isempty(cind)
                    warning('no match found')
                    return
                end

                cridfs(:,besti) = bestridfs{besti,csnapszhti}(cind,:);
%                 snaps(besti) = bestsnap{besti,csnapszhti}(cind);
%                 fprintf('best snap: %d\n',bestsnap{besti,csnapszhti}(cind));
            end
        else
            for besti = 1:length(zht)
                cind = find(all(bsxfun(@eq,imxyi{besti,csnapszhti},[xi yi]),2),1);
                if isempty(cind)
                    warning('no match found')
                    return
                end

                cridfs(:,besti) = bestridfs{besti,csnapszhti}(cind,:);
%                 snaps(besti) = bestsnap{besti,csnapszhti}(cind);
%                 fprintf('best snap: %d\n',bestsnap{besti,csnapszhti}(cind));
            end
        end

        ths = repmat(linspace(-180,180,size(cridfs,1)+1)',1,size(cridfs,2));
        cridfs = circshift(cridfs,floor(size(cridfs,1)/2));
        cridfs(end+1,:) = cridfs(1,:);

        h=plot(ths,cridfs);
        h(zht==snapszht(csnapszhti)).LineStyle='--';
        xlim([-180 180])
        set(gca,'XTick',-180:90:180)
        xlabel('Angle (deg)')
        title(sprintf('(%d, %d) Training height: %d mm',gx,gy,snapszht(csnapszhti)+50))
        title(legend(num2str((zht+50)')),'Height (mm)')

        g_fig_setfont
        andy_setbox
    end

    function showdiffim(xi,yi)
        warning('snapshots are broken in this function (wrong zi)')
        
        whd = fullfile(g_dir_imdb,shortwhd);
        
        % get the image for the clicked position
        im = g_imdb_getim(whd,xi,yi,czhti);
        
        % get best-matching snap for this position
        snapi = bestsnap{czhti,csnzhti};
        posi = find(imxi==xi & imyi==yi);
        snxi = find(p.xs==snx(snapi(posi)));
        snyi = find(p.ys==sny(snapi(posi)));
        snap = g_imdb_getim(whd,snxi,snyi,csnzhti);
        
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
