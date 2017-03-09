function imdb_ridferrsbyrowchunked(whfig,dosave)
if nargin < 2
    dosave = false;
end
if nargin < 1
    whfig = 1;
else
    whfig = 10^(whfig-1);
end

[fd,whd,refxi,refyi,p,label] = imdb_getfigdat_ridferrsbyrowchunked(true);

ehc = 1-cosd(min(90,abs(fd.headsbychunk(:,:))));
nchunk = size(ehc,1);
mehc = nanmean(ehc,2);
sehc = nanstd(ehc,[],2);

figure(1*whfig);clf
subplot(2,2,1)
barh(1:nchunk,mehc,'w')
xlim([0 1])
set(gca,'YDir','reverse')
title(whd,'Interpreter','none')
ylabel('which slice (from top)')
xlabel('mean error over arena')

subplot(2,2,2)
barh(1:nchunk,sehc,'w')
set(gca,'YDir','reverse')
xlim([0 1])
set(gca,'YTick',[])
xlabel('std')

load('gantry_cropparams.mat');
refim = imdb_getim(whd,refyi,refxi);
refim = refim(y1:y2,:);
subplot(2,2,3:4)
imshow(refim)
hold on
chunkht = 10;
for i = 1:nchunk
    y = min(size(refim,1),chunkht*i);
    plot(xlim,[y y],'r')
end

figure(2*whfig);clf
hold on
if ~isempty(p.arenafn)
    load(p.arenafn);
    drawobjverts(objverts,'k')
end
anglequiver(p.xs,p.ys,fd.heads);
plot(p.xs(refxi),p.ys(refyi),'ro','LineWidth',4,'MarkerSize',10)
axis equal tight
xlabel('x (mm)')
ylabel('y (mm)')
title(label)

if dosave
    savefig(['ridf_heads_' label],[15 12])
end

dump2base(true)