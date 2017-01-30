function gantry_rf_recap(fnind,sttrial,stoffs,ststep)
% clear
if ~nargin
    sttrial = 1;
    stoffs = 1;
end
% TODO: add capability to resume

pr.ntrialsperroute = 1;
arenafn = []; %'arena1_boxes';
whroute = 5;
pr.dummy = false;
pr.fov = 360;
pr.turnmax = 90;

turnmaxrad = pr.turnmax*pi/180;

datadir = fullfile(mfiledir,'routedat','data');

pr.maxlen = 2; % times the length of the route

routefn = sprintf('route_%s_%03d',matfileremext(arenafn),whroute);
load(fullfile(mfiledir,'routedat',routefn))
snfn = sprintf('snaps_%s_fov%03d',routefn,pr.fov);
% if fov==360
%     rd = load(rdataffn);
%     snths = atan2(diff(rd.cly),diff(rd.clx));
%     snths(end+1) = snths(end);
% else
load(fullfile(mfiledir,'routedat',routefn),'p','clx','cly','cli','whclick','rclx','rcly','ptr');
pr.routedat_p = p;

pr.stepsize = p.snapsep*1000/p.arenascale;
pr.maxdistfromroute = 2*pr.stepsize;
pr.stopdistfromend = pr.stepsize; % distance from end of route at which to stop
pr.routegridsep = 1;
pr.zht_mean = 200;
pr.zht_std = pr.zht_mean/2;
pr.head_noise_std = 2; % degrees
pr.snapweighting = 'infomax120'; %'wta'; %{'norm',5};
pr.nth = 360;

if startswith(pr.snapweighting,'infomax')
    snwt = parseweightstr(pr.snapweighting);
    load(fullfile(mfiledir,'routedat',sprintf('infomax_%s_w%03d.mat',snfn,snwt{2})),'imsz','W')
    isinfomax = true;
else
    load(fullfile(mfiledir,'routedat',snfn));
    isinfomax = false;
end

if isempty(arenafn)
    pr.objzht = pr.zht_mean;
else
    load(fullfile(mfiledir,arenafn),'objhts')
    pr.objzht = max(objhts);
end

pr.maxV = [240;240;151];
pr.maxA = [20;20;20];

% alexGantry(debug, homeGantry, disableZ, acuity, maxV, maxA, showvidpreview, simulate)
g = alexGantry(false,true,false,1,pr.maxV,pr.maxA,false,pr.dummy);

[objim,badzone,oxs,oys,goxs,goys] = gantry_getbadzoneim(arenafn,p.objgridac,p.headclear,eps(0));
% oxs = p.arenascale*oxs/1000;
% oys = p.arenascale*oys/1000;

rclx = round(rclx*1000/p.arenascale);
rcly = round(rcly*1000/p.arenascale);
rclxfull = num2cell(rclx(1,:));
rclyfull = num2cell(rcly(1,:));
whclick  = num2cell(ones(1,size(rclx,2)));
for i = 1:size(rclx,1)-1
    xdiff = diff(rclx([i i+1],:));
    ydiff = diff(rcly([i i+1],:));
    crad = round(hypot(xdiff,ydiff));
    cnstep = crad/pr.routegridsep; %(pr.stepsize*1000/p.arenascale);
    %     if ~all(floor(cnstep)==cnstep)
    %         error('not a round number of steps between specified route points')
    %     end
    for j = 1:size(rclx,2)
        rcurx = round(rclx(i,j)+(xdiff(j)/cnstep(j))*(1:cnstep)');
        rclxfull{j} = [rclxfull{j}; rcurx];
        rclyfull{j} = [rclyfull{j}; round(rcly(i,j)+(ydiff(j)/cnstep(j))*(1:cnstep)')];
        whclick{j} = [whclick{j}; (i+1)*ones(size(rcurx))];
    end
end

load('gantry_centrad.mat','unwrapparams');
pr.unwrapparams = unwrapparams;
pr.crop = load('gantry_cropparams.mat');

pr.maxnsteps = ceil(pr.maxlen*sum(hypot(diff(rclx),diff(rcly)),1)/pr.stepsize);
% pr.maxnsteps = 20*ones(1,size(rclx,2));

if nargin
    disp('LOADING DATA')
    cdatadir = fullfile(datadir,sprintf('%s_%03d',routefn,fnind));
    load(fullfile(cdatadir,'params.mat'),'pr');
    
    %     load(fullfile(cdatadir,sprintf('trial%04d_offs%04d_step%04d.mat',
else
    fnind = 1;
    while true
        cdatadir = fullfile(datadir,sprintf('%s_%03d',routefn,fnind));
        if ~exist(cdatadir,'dir')
            mkdir(cdatadir)
            break
        end
        fnind = fnind+1;
    end
    paramfn = fullfile(cdatadir,'params.mat');
    savemeta(paramfn,'pr');
    
    d.curx = 0;
    d.cury = 0;
end

noffs = length(p.startoffs);
ntrialtot = noffs*pr.ntrialsperroute;
load('arenadim.mat','lim')
pausefig;
tott=tic;
pauset=0;
for i = sttrial:pr.ntrialsperroute
    if i==sttrial
        offsi = stoffs:noffs;
    else
        offsi = 1:noffs;
    end
    for j = offsi
        %         if nargin && i==sttrial &&
        if ~nargin || i~=sttrial || j~=stoffs
            d.toterrs = 0;
        end
        
        fprintf('starting trial %d/%d at offset %g (%d/%d) [%d/%d total]\n', ...
            i,pr.ntrialsperroute,p.startoffs(j),j,length(p.startoffs),(i-1)*noffs+j,ntrialtot);
        
        g.moveToPoint([d.curx d.cury pr.objzht]) % raise gantry head
        % move to start position
        d.curx = rclxfull{j}(1);
        d.cury = rclyfull{j}(1);
        d.curz = newzht(pr,lim);
        g.moveToPoint([d.curx d.cury pr.objzht])
        g.moveToPoint([d.curx d.cury d.curz])
        
        d.curth = atan2(diff(rcly(1:2,j)),diff(rclx(1:2,j)));
        
        for k = 1:pr.maxnsteps(j)
            fprintf('step %d (%d max) (offset %d/%d)\n',k,pr.maxnsteps(j),j,noffs)
            
            d.curfr = gantry_processim(rgb2gray(g.getRawFrame),pr.unwrapparams,pr.crop);
            if isinfomax
                [d.head,d.minval,d.ridfs] = infomax_gethead(d.curfr,imsz,W,[],pr.nth,pr.fov);
                d.whsn = [];
            else
                [d.head,d.minval,d.whsn,d.ridfs] = ridfheadmulti(d.curfr,fovsnaps,pr.snapweighting,[],pr.nth);
            end

            d.headnoise = capminmax(randn*pr.head_noise_std*pi/180,-pi,pi);
            thnoise = d.head+d.headnoise;
            d.dth = circ_dist(d.curth,thnoise);
            if abs(d.dth) > turnmaxrad
                d.bear = pi2pi(d.curth-sign(d.dth)*turnmaxrad);
            else
                d.bear = pi2pi(thnoise);
            end
            
            fprintf('bearing: %.2f deg (max = %d)\n',(180/pi)*d.bear,pr.turnmax);
            
            d.bear = sign(d.bear)*min(pr.turnmax*pi/180,abs(d.bear));
            
            [dx,dy] = pol2cart(d.bear,pr.stepsize);
            d.goalx = round(d.curx+dx);
            d.goaly = round(d.cury+dy);
            [~,d.goalxi] = min(abs(d.goalx-oxs));
            [~,d.goalyi] = min(abs(d.goaly-oys));
            
            % (could only check shortest route if not also about to collide)
            dists = hypot(rclyfull{j}-d.goaly,rclxfull{j}-d.goalx);
            [d.shortestdisttoroute,d.whnearest] = min(dists);
            fprintf('(%g m from route)\n',d.shortestdisttoroute*p.arenascale/1000);
            %             [sdists,dI] = sort(dists);
            %             for l = 1:length(dists)
            %                 if dI(l)==1
            %                     x = rclx(1:2,j);
            %                     y = rcly(1:2,j);
            %                 else
            %                     x = rclx(i:i+1,j);
            %                     y = rcly(i:i+1,j);
            %                 end
            %                 m = diff(y)/diff(x);
            %                 c = y(1)-m*x(1);
            %                 mperp = -1/m;
            %                 cperp = d.goaly+mperp*d.goalx;
            %                 sol = [m 1; mperp 1]'*[c; cperp];
            %                 keyboard
            %             end
            d.bad_collision = badzone(d.goalyi,d.goalxi);
            d.bad_distfromroute = d.shortestdisttoroute > pr.maxdistfromroute;
            d.bad_outofarena = d.goalx < 0 || d.goalx > lim(1) || d.goaly < 0 || d.goaly > lim(2);
            d.isbad = d.bad_collision | d.bad_distfromroute | d.bad_outofarena;
            
            cdatafn = fullfile(cdatadir,sprintf('trial%04d_offs%04d_step%04d.mat',i,j,k));
            save(cdatafn,'d');
            if d.isbad
                if d.bad_collision
                    disp('bad heading (collision)')
                end
                if d.bad_distfromroute
                    fprintf('bad heading (%g from route)\n',d.shortestdisttoroute)
                end
                if d.bad_outofarena
                    disp('bad heading (out of arena)')
                end
                
                nextI = min(length(rclxfull{j}),d.whnearest+round(pr.stepsize/pr.routegridsep));
                d.curx = rclxfull{j}(nextI);
                d.cury = rclyfull{j}(nextI);
                d.curth = atan2(diff(rclyfull{j}(nextI-1:nextI)),diff(rclxfull{j}(nextI-1:nextI)));
                
                d.toterrs = d.toterrs+1;
            else
                d.curx = d.goalx;
                d.cury = d.goaly;
                d.curth = d.bear;
            end
            
            if ~ishandle(1)
                pausetic = tic;
                input('Press enter to continue. REMEMBER TO UNDO STOP BUTTON. ')
                pausefig;
                pauset = pauset+toc(pausetic);
            end
            
            distfromend = hypot(rcly(end,j)-d.cury,rclx(end,j)-d.curx);
            fprintf('(%g m from end)\n',distfromend)
            if distfromend <= pr.stopdistfromend
                disp('REACHED END OF ROUTE')
                break
            end
            
            d.curz = newzht(pr,lim);
            g.moveToPoint([d.curx d.cury d.curz]);
        end
        if k==pr.maxnsteps(j)
            fprintf('REACHED MAX NUM STEPS (%d)\n',pr.maxnsteps(j))
        end
        
        fprintf('%d errors in total\n',d.toterrs);
    end
end
tsec = toc(tott)-pauset;
tmin = floor(tsec/60);
fprintf('Job completed in %02d:%02d.\n',tmin,mod(round(tsec),60));

g.homeGantry(false)
delete(g)

% routeth = atan2(cly(2)-cly(1),clx(2)-clx(1));
% [xoff,yoff] = pol2cart(pi/2+routeth,pr.startoffs);
% pr.stx = xoff+mean(clx(1:2));
% pr.sty = yoff+mean(cly(1:2));

% [objim,~,oxs,oys] = gantry_getbadzoneim(arenafn,p.objgridac,p.headclear,p.zht);
% oxs = p.arenascale*oxs/1000;
% oys = p.arenascale*oys/1000;
%
% figure(1);clf
% image(oxs,oys,objim)
% set(gca,'YDir','normal')
% hold on
% plot(clx,cly,clx,cly,'b+',stx,sty,'g+')

end

function genzht=newzht(pr,lim)
genzht = capminmax(pr.zht_mean+randn*pr.zht_std,0,lim(3));
end

function pausefig
figure(1);clf
title('close me to pause program')
drawnow
end
