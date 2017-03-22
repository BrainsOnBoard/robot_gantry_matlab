function g_live_recap_examinedata
% clear

wharena = 'arena1_boxes';
whroute = 1;
whdataset = 2;

datadir = fullfile(mfiledir,'routedat','data');

datafn = fullfile(datadir,sprintf('comb_route_%s_%03d_%03d.mat',wharena,whroute,whdataset));
load(datafn)
% x = cell2mat(combd.curx);
% y = cell2mat(combd.cury);
% goalx = cell2mat(combd.goalx);
% goaly = cell2mat(combd.goaly);
% isbad = cell2mat(combd.isbad)==1;
p = pr.routedat_p;

[objim,~,oxs,oys] = gantry_getbadzoneim(wharena,p.objgridac,p.headclear);
oxs = oxs*p.arenascale/1000;
oys = oys*p.arenascale/1000;

% figure(1);clf
%
% alsubplot(1,2,1,1)
% image(oxs,oys,objim)
% set(gca,'YDir','normal')
% axis equal
% xlim([0 max(oxs(:))])
% ylim([0 max(oys(:))])
% hold on
% plot(rd.rclx,rd.rcly,'k',rd.clx,rd.cly,'kx'); %,x,y,'+-',x(isbad),y(isbad),'r+')
%
% cols = get(gca,'ColorOrder');
% nsteps = zeros(length(p.startoffs),1);
% for i = 1:length(p.startoffs)
%     x = combd.curx{i};
%     y = combd.cury{i};
%     for j = 1:size(x,1)-1
%         if isnan(combd.isbad{i}(j))
%             break;
%         elseif combd.isbad{i}(j)==1
%             plot([x(j) combd.goalx{i}(j)],[y(j) combd.goaly{i}(j)],'Color',cols(i,:))
%             plot(x(j:j+1),y(j:j+1),':+','Color',cols(i,:))
%             plot(x(j),y(j),'r+')
%         else
%             plot(x(j:j+1),y(j:j+1),'-+','Color',cols(i,:))
%         end
%         nsteps(i) = nsteps(i)+1;
%     end
% end
%
% title(sprintf('arena: %s; route: %d; weight: %s',wharena,whroute,pr.snapweighting),'interpreter','none')

snfn = fullfile(mfiledir,'routedat',sprintf('snaps_route_%s_%03d_fov%03d.mat',wharena,whroute,pr.fov));
load(snfn);

keys = keydef;

cdatadir = fullfile(datadir,sprintf('route_%s_%03d_%03d',wharena,whroute,whdataset));
cstartoffs = 3;
ctrial = 1;
cstep = 1;

load(getfn(cdatadir,ctrial,cstartoffs,cstep));
while true
    figure(1);clf
    
    alsubplot(5,1,1,1)
    image(oxs,oys,objim)
    set(gca,'YDir','normal')
    axis equal
    xlim([0 max(oxs(:))])
    ylim([0 max(oys(:))])
    hold on
    plot(rd.rclx,rd.rcly,'k',rd.clx,rd.cly,'kx'); %,x,y,'+-',x(isbad),y(isbad),'r+')
    
    cols = get(gca,'ColorOrder');
    nsteps = zeros(length(p.startoffs),1);
    for i = 1:length(p.startoffs)
        x = combd.curx{i};
        y = combd.cury{i};
        for j = 1:size(x,1)-1
            if isnan(combd.isbad{i}(j))
                break;
            elseif combd.isbad{i}(j)==1
                plot([x(j) combd.goalx{i}(j)],[y(j) combd.goaly{i}(j)],'Color',cols(i,:))
                plot(x(j:j+1),y(j:j+1),':+','Color',cols(i,:))
                plot(x(j),y(j),'r+')
            else
                plot(x(j:j+1),y(j:j+1),'-+','Color',cols(i,:))
            end
            
            if i==cstartoffs && j==cstep
                plot(x(j),y(j),'ko')
            end
            nsteps(i) = nsteps(i)+1;
        end
    end
    
    title(sprintf('arena: %s; route: %d; weight: %s',wharena,whroute,pr.snapweighting),'interpreter','none')
    
    rfr = circshift(d.curfr,1+round(d.head*(size(d.curfr,2)-1)/(2*pi)),2);
    alsubplot(2,1)
    imshow(rfr)
    title('current view')
    
    csn=fovsnaps(:,:,d.whsn);
    alsubplot(3,1)
    imshow(csn)
    title(sprintf('snap (i=%d)',d.whsn))
    
    imdiff=im2double(rfr)-im2double(csn);
    imdiff=imdiff/max(abs(imdiff(:)));
    alsubplot(4,1)
    imshow(1+imdiff/2)
    
    alsubplot(5,1)
    plot(d.ridfs(:,d.whsn))
    
    [~,~,but] = ginput(1);
    switch but
        case keys.Up
            cstep = max(1,cstep-1);
        case keys.Down
            cstep = min(nsteps(cstartoffs),cstep+1);
        case keys.Right
            cstartoffs = max(1,cstartoffs-1);
            cstep = min(nsteps(cstartoffs),cstep);
        case keys.Left
            cstartoffs = min(length(p.startoffs),cstartoffs+1);
            cstep = min(nsteps(cstartoffs),cstep);
        case keys.Esc
            break
        otherwise
            continue
    end
    
    cfn = getfn(cdatadir,ctrial,cstartoffs,cstep);
    load(cfn,'d')
end

dump2base(true)

function fn=getfn(cdatadir,ctrial,cstartoffs,cstep)
fn = fullfile(cdatadir,sprintf('trial%04d_offs%04d_step%04d.mat',ctrial,cstartoffs,cstep));