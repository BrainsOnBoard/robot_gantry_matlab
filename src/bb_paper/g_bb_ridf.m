function g_bb_ridf(shortwhd,routenum,zht,snapszht,userealsnaps,improc,coords,shiftridfs,dosave,joinpdfs,figtype,doautoridf)
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
if nargin < 12
    doautoridf = false;
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

if ~isempty(coords) % empty coords signals interactive mode
    if joinpdfs
        g_fig_series_start
    end
    for i = 1:size(coords,1)
        % get corresponding grid coords
        xi = find(p.xs==coords(i,1));
        yi = find(p.ys==coords(i,2));
        
        plotridfs(xi,yi)
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
else
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

                plotridfs(xi,yi)
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
end

    function showquiver
        g_bb_quiver(shortwhd,routenum,zht(czhti),snapszht(csnzhti),userealsnaps,false,improc,true,false);
    end

    function plotridfs(xi,yi)
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
            % get RIDF for best match
            cridfs = NaN(imsz(2),length(zht));
%             snaps = NaN(length(zht),1);
            if doautoridf
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
            
            subplot(sprows,spcols,csnapszhti)
            h=plot(ths,cridfs);
            h(csnapszhti).LineStyle='--';
            xlim([-180 180])
            set(gca,'XTick',-180:90:180)
            xlabel('Angle (deg)')
%             title(sprintf('x=%d, y=%d, snapszht=%dmm',gx,gy,snapszht(csnapszhti)+50))
            title(sprintf('(%d, %d) Training height: %d mm',gx,gy,snapszht(csnapszhti)+50))
            title(legend(num2str((zht+50)')),'Height (mm)')
            
            g_fig_setfont
            andy_setbox
            
            yl = ylim;
            ymax = max(yl(2),ymax);
        end
        for csnapszhti = 1:length(snapszht)
            subplot(sprows,spcols,csnapszhti)
            ylim([0 ymax])
        end
    end
end
