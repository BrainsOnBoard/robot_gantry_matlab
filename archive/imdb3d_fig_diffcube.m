clear

[imdir,imdirshort] = g_imdb_choosedb;

dosave = true;

load(fullfile(imdir,'im_params.mat'))

zref = 200;

zrefi = find(p.zs==zref);
xrefi = round(length(p.xs)/2);
yrefi = round(length(p.ys)/2);

nfigrow = 2;

diffs = imdb3d_fig_diffcube_gendata(imdirshort,xrefi,yrefi,zrefi)/255;

zmax = 0.05;
figure(1);clf
for i = 1:length(p.zs)
    subplot(nfigrow,ceil(length(p.zs)/nfigrow),i);
    surf(p.xs',p.ys',diffs(:,:,i)')
    t=title(sprintf('z = %.2f mm',p.zs(i)));
    if i==zrefi
        set(t,'Color','r')
    end
    zlim([0 zmax])
    hold on
    plot3(p.xs(xrefi),p.ys(yrefi),0,'r+')
end

if dosave
    savefig(['diffcube_' imdirshort],[30 20]);
end