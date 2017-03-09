clear

load('arenadim.mat')

g = gantry_default;
g.home_gantry(false);
g.move([0;lim(2)/2;500])

v = VideoWriter('outfile.avi');
v.open;
figure(1);clf
t=[];
while ishandle(1)
    tic
    v.writeVideo(g.getRawFrame);
    t=[t,toc];
end
v.close;

delete(g)

save('outfile.mat','t')