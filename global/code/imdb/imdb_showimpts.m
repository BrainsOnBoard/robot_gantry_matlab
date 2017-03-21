clear

whd = g_imdb_choosedb;
load(fullfile(whd,'im_params.mat'))

figure(10);clf
xlim([0 p.lim(1)])
ylim([0 p.lim(2)])
hold on

fex = false(length(p.ys),length(p.xs));
for xi = 1:length(p.xs)
    for yi = 1:length(p.ys)
        fex(yi,xi) = exist(fullfile(whd,sprintf('im_%03d_%03d_001.mat',xi,yi)),'file');
        if fex(yi,xi)
            plot(p.xs(xi),p.ys(yi),'g+')
        else
            plot(p.xs(xi),p.ys(yi),'r+')
        end
    end
end
