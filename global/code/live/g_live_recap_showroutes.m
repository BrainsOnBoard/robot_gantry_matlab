clear

wharena = 'arena2_pile';
whroute = 1;
whdataset = 2;
dosave = false;

datafn = fullfile(mfiledir,'routedat','data',sprintf('comb_route_%s_%03d_%03d.mat',wharena,whroute,whdataset));
load(datafn)
% x = cell2mat(combd.curx);
% y = cell2mat(combd.cury);
% goalx = cell2mat(combd.goalx);
% goaly = cell2mat(combd.goaly);
% isbad = cell2mat(combd.isbad)==1;
p = pr.routedat_p;

[objim,~,oxs,oys] = g_arena_getbadzone(wharena,p.objgridac,p.headclear);
oxs = oxs*p.arenascale/1000;
oys = oys*p.arenascale/1000;

figure(1);clf
image(oxs,oys,objim)
set(gca,'YDir','normal')
axis equal
xlim([0 max(oxs(:))])
ylim([0 max(oys(:))])
hold on
plot(rd.rclx,rd.rcly,'k',rd.clx,rd.cly,'kx'); %,x,y,'+-',x(isbad),y(isbad),'r+')

cols = get(gca,'ColorOrder');
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
    end
end

title(sprintf('arena: %s; route: %d; weight: %s',wharena,whroute,pr.snapweighting),'interpreter','none')

if dosave
    savefig(sprintf('showroute_%s_%03d',wharena,whroute),[20 20])
end