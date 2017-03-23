function g_live_train_showpath
%G_LIVE_TRAIN_SHOWPATH   Show stored training paths.

arenafn = []; %'arena1_boxes';
datadir = fullfile(mfiledir,'routedat');
arenascale = 10;

d = dir(fullfile(datadir,['route_' matfileremext(arenafn) '_*.mat']));

[objim,~,oxs,oys] = g_arena_getbadzone(arenafn,10,150);
oxs = arenascale*oxs/1000;
oys = arenascale*oys/1000;

load('arenadim')
lim = arenascale*lim/1000;

figure(1);clf
image(oxs,oys,objim)
axis equal
set(gca,'YDir','normal')
xlim([0 lim(1)])
ylim([0 lim(2)])
hold on

fns = {d.name};
for i = 1:length(d)
    load(fullfile(datadir,fns{i}),'clx','cly')
    plot(clx,cly)
end
% legend(fns{:})