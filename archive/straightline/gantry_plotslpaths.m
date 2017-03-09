clear

datadir = fullfile(mfiledir,'sl_dat');
fs = dir(fullfile(datadir,'dat_*.mat'));

[xs,ys] = deal(cell(1,length(fs)));
for i = 1:length(fs)
    load(fullfile(datadir,fs(i).name));
    xs{i} = d.nextx;
    ys{i} = d.nexty;
end

%%
aroff = 100;
col = 'bgrmc';
load('arenadim.mat')
figure(1);clf
hold on
line([0 lim(1) lim(1) 0 0],[0 0 lim(2) lim(2) 0],'Color','k')
xlim([-aroff lim(1)+aroff])
ylim([-aroff lim(2)+aroff])
for i = 1:length(fs)
    plot(xs{i},ys{i},[col(1+mod(i-1,length(col))) '-x'])
end
axis equal