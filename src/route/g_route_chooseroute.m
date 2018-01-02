function g_route_chooseroute(arenafn,startoffs)
%G_ROUTE_CHOOSEROUTE   Set the training path for a new experiment.
%   G_ROUTE_CHOOSEROUTE('arena1.mat') specifies the arena (where
%   objects are).
%   If no arena is specified, the arena is assumed to be empty.

if nargin < 2
    p.startoffs = 0;
else
    p.startoffs = startoffs;
end
if nargin < 1
    p.arenafn = [];
else
    p.arenafn = arenafn;
end

p.headclear = 150;
p.objgridac = 10;

p.arenascale = 20; % * true size
p.snapsep = 0.50; % m
p.stepsize = p.snapsep;
p.routeinterpdist = 0.01; % m
p.recapstartoffs = -p.stepsize; % how far along route to start recap (so as not to start at the same pos as first snap)
p.datadir = g_dir_routes; % where should we save data?

if ~exist(p.datadir,'dir')
    mkdir(p.datadir)
end

% get details of where objects are in arena, and the "bad zone" (the area
% within which the gantry cannot go, which encompasses the area around
% boxes)
[objim,badzone,oxs,oys,goxs,goys] = g_arena_getbadzone(p.arenafn,p.objgridac,p.headclear);

% scale the object xs and ys to our scale
oxs = p.arenascale*oxs/1000;
oys = p.arenascale*oys/1000;
goxs = p.arenascale*goxs(:)/1000;
goys = p.arenascale*goys(:)/1000;

ipts = 1:numel(badzone);
[iy,ix] = ind2sub(size(badzone),ipts);

% xs and ys for drawing circles
[circx,circy] = pol2cart(linspace(0,2*pi,1000),p.snapsep);

% the physical limits of the arena
load('arenadim.mat','lim')
lim = p.arenascale*lim/1000; % convert to our scale

ccnt = 1; % click count (minus bad clicks)
[clx,cly,cli,whclick] = deal([]);
[chigher,sgn] = deal(ones(2,1));
closing = false;
try
    while true
        figure(1)
        image(goxs,goys,objim) % show the objects and bad zone
        axis equal
        set(gca,'YDir','normal') % y direction is not inverted
        ylim([0 lim(2)])
        xlim([0 lim(1)])
        grid on
        hold on
        
        % draw circles where snapshots have been taken
        plot(clx,cly,clx,cly,'b+')
        for i = 1:length(cli)
            plot(clx(i)+circx,cly(i)+circy,'b')
        end
        
        % show in green where user clicked, and parallel routes (startoffs)
        if ccnt >= 3
            plot(rclx,rcly,'g+')
        end
        if ccnt >= 4 || (ccnt==3 && closing)
            plot(rclx,rcly,'g')
        end
        
        % if user has pressed return to finish
        if closing
            break;
        end
        
        [gx,gy,but] = ginput(1); % get user click/keypress
        if ccnt==1 % first run
            x2 = gx;
            y2 = gy;
        else
            lasti2 = find(ccnt-1==whclick,1,'last');
            x2 = clx(lasti2);
            y2 = cly(lasti2);
        end
        
        if isempty(but) % return pressed
            if ccnt >= 2
                lasti1 = find(ccnt-2==whclick,1,'last');
                x1 = clx(lasti1);
                y1 = cly(lasti1);
                
                morig = (y2-y1)/(x2-x1); % gradient of current route line
                corig = y2-morig*x2; % y intercept
                mperp = -1/morig; % perpendicular gradient, for parallel routes
                cperp = y2-mperp*x2; % perpendicular y intercept
                
                sgnold = sgn;
                sgn(2) = sign(dx1);
                if ~any(sgn)==0 && sgn(2)~=sgn(1)
                    chigher(2) = -chigher(2);
                end
                
                cpar = corig+p.startoffs*chigher(2)*hypot(1,morig);
                
                if morig==0 % horizontal line
                    xint = x2*ones(size(p.startoffs));
                    yint = rcly(end,:);
                elseif mperp==0 % vertical line
                    xint = rclx(end,:);
                    yint = y2*ones(size(p.startoffs));
                else
                    xint = (cperp-cpar)./(morig-mperp);
                    yint = morig*xint+cpar;
                end
                rclx(end+1,:) = xint;
                rcly(end+1,:) = yint;
                
                [~,whxst] = min(abs(bsxfun(@minus,oxs',stenx(1,:))));
                [~,whyst] = min(abs(bsxfun(@minus,oys',steny(1,:))));
                [whiist,~] = find(bsxfun(@eq,oys(whyst),goys) & bsxfun(@eq,oxs(whxst),goxs));
                whiist = whiist';
                [~,whxen] = min(abs(bsxfun(@minus,oxs',stenx(2,:))));
                [~,whyen] = min(abs(bsxfun(@minus,oys',steny(2,:))));
                [whiien,~] = find(bsxfun(@eq,oys(whyen),goys) & bsxfun(@eq,oxs(whxen),goxs));
                whiien = whiien';
                ind = [whiist;whiien];
                clickim = imbwdrawline(false(size(badzone)),ix(ind),iy(ind));
                
                if any(clickim(:) & badzone(:))
                    rclx = rclx(1:end-1,:);
                    rcly = rcly(1:end-1,:);
                    sgn = sgnold;
                else
                    closing = true;
                end
            end
        elseif but==1 % left click
            curdx = gx-x2;
            curdy = gy-y2;
            [cth,cr] = cart2pol(curdx,curdy);
            
            rs = p.snapsep*(0:round(cr/p.snapsep));
            [xoff,yoff]=pol2cart(cth,rs);
            curx = x2+xoff;
            cury = y2+yoff;
            
            [stenx,steny] = deal(NaN(2,1+length(p.startoffs)));
            stenx(1:2,1) = curx([1 end])';
            steny(1:2,1) = cury([1 end])';
            
            dx1 = xoff(end);
            dy1 = yoff(end);
            
            sgnold = sgn;
            
            if ccnt==2
                sgn(1) = sign(dx1);
                
                [rxoff,ryoff] = rotatexy(p.recapstartoffs,sgn(1)*p.startoffs,cth);
                rclx = x2+rxoff;
                rcly = y2+ryoff;
                
                stenx(1:2,2:end) = repmat(rclx,2,1);
                steny(1:2,2:end) = repmat(rcly,2,1);
            elseif ccnt > 2
                sgn(2) = sign(dx1);
                if ~any(sgn)==0 && sgn(2)~=sgn(1)
                    chigher(2) = -chigher(2);
                end
                
                lasti1 = find(ccnt-2==whclick,1,'last');
                x1 = clx(lasti1);
                y1 = cly(lasti1);
                
                dx2 = (x2-x1);
                dy2 = (y2-y1);
                m = [dy2/dx2;dy1/dx1];
                corig = y2-m.*x2;
                
                c = bsxfun(@plus,corig,bsxfun(@times,p.startoffs,chigher.*hypot(1,m)));
                xint = (c(2,:)-c(1,:))./(m(1)-m(2));
                yint = m(1,:)*xint+c(1,:);
                rclx(ccnt-1,:) = xint;
                rcly(ccnt-1,:) = yint;
                
                stenx(1:2,2:end) = rclx(end-1:end,:);
                steny(1:2,2:end) = rcly(end-1:end,:);
                
                sgn(1) = sgn(2);
                chigher(1) = chigher(2);
            end
            
            if ccnt==1
                [~,whxst] = min(abs(bsxfun(@minus,oxs',stenx(1,1))));
                [~,whyst] = min(abs(bsxfun(@minus,oys',steny(1,1))));
                [whiist,~] = find(bsxfun(@eq,oys(whyst),goys) & bsxfun(@eq,oxs(whxst),goxs));
                clickim = false(size(badzone));
                clickim(whiist) = true;
            else
                [~,whxst] = min(abs(bsxfun(@minus,oxs',stenx(1,:))));
                [~,whyst] = min(abs(bsxfun(@minus,oys',steny(1,:))));
                [whiist,~] = find(bsxfun(@eq,oys(whyst),goys) & bsxfun(@eq,oxs(whxst),goxs));
                whiist = whiist';
                [~,whxen] = min(abs(bsxfun(@minus,oxs',stenx(2,:))));
                [~,whyen] = min(abs(bsxfun(@minus,oys',steny(2,:))));
                [whiien,~] = find(bsxfun(@eq,oys(whyen),goys) & bsxfun(@eq,oxs(whxen),goxs));
                whiien = whiien';
                ind = [whiist;whiien];
                clickim = imbwdrawline(false(size(badzone)),ix(ind),iy(ind));
            end
            
            if any(clickim(:) & badzone(:))
                rclx = rclx(1:end-1,:);
                rcly = rcly(1:end-1,:);
                sgn = sgnold;
            else
                if ccnt > 1
                    curx = curx(2:end);
                    cury = cury(2:end);
                end
                
                [~,whx] = min(abs(bsxfun(@minus,oxs',curx)));
                [~,why] = min(abs(bsxfun(@minus,oys',cury)));
                [whii,~] = find(bsxfun(@eq,oys(why),goys) & bsxfun(@eq,oxs(whx),goxs));
                
                clx = [clx, curx];
                cly = [cly, cury];
                cli = [cli, whii'];
                whclick = [whclick, ccnt*ones(size(curx))];
                ccnt = ccnt+1;
            end
        elseif but==3 % right click
            ccnt = max(1,ccnt-1);
            lastclick = find(whclick==ccnt-1,1,'last');
            cli = cli(1:lastclick);
            clx = clx(1:lastclick);
            cly = cly(1:lastclick);
            rclx = rclx(1:max(0,ccnt-2),:);
            rcly = rcly(1:max(0,ccnt-2),:);
            whclick = whclick(1:lastclick);
        end
    end
    
    if ccnt > 1
        fnum = 1;
        while true
            p.filename = fullfile(p.datadir,sprintf('route_%s_%03d.mat',matfileremext(p.arenafn),fnum));
            if ~exist(p.filename,'file')
                break
            end
            fnum = fnum+1;
        end
        
        fprintf('Saving to %s...\n',p.filename)
        save(p.filename,'p','clx','cly','cli','whclick','rclx','rcly')
    end
catch ex
    if ~strcmp(ex.identifier,'MATLAB:ginput:FigureDeletionPause') && ~strcmp(ex.identifier,'MATLAB:ginput:Interrupted')
        rethrow(ex)
    end
end
