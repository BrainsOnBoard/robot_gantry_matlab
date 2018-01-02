clear

wharena = 'arena1_boxes';
whroute = 1;
whdataset = 4;

datafn = fullfile(mfiledir,'routedat','data',sprintf('route_%s_%03d_%03d_comb.mat',wharena,whroute,whdataset));
load(datafn)
x = cell2mat(x);
y = cell2mat(y);
th = cell2mat(th);
isbad = cell2mat(isbad);
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
plot(rd.rclx,rd.rcly,'k',rd.clx,rd.cly,'kx',x,y) %,x,y,'+-',x(isbad),y(isbad),'r+')
anglequiver(x,y,th)