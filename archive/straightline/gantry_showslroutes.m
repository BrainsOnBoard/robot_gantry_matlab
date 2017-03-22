clear

arenafn = 'arena1_boxes.mat';
objgridac = 10;
headclear = 150;

[objim,~,oxs,oys] = g_arena_getbadzone(arenafn,objgridac,headclear);

figure(2);clf
image(oxs,oys,objim)
set(gca,'YDir','normal')
hold on

d = dir(fullfile(mfiledir,['sl_' matfileremext(arenafn) '_*.mat']));
for i = 1:length(d)
    load(fullfile(mfiledir,d(i).name),'clx','cly')
    plot(clx,cly,'g',clx,cly,'b+')
end