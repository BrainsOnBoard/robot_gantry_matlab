function g_live_train_unwrapsnaps(arenafn,whroute)

rfn = sprintf('route_%s_%03d',matfileremext(arenafn),whroute);
snapdir = fullfile(g_dir_routes_snapshots,['snaps_' rfn]);

load('gantry_centrad','unwrapparams')
crop = load('gantry_cropparams.mat');
nfile = length(dir(fullfile(snapdir,'*.mat')));
if nfile==0
    error('no snapshots found')
end
snaps = zeros([crop.y2-crop.y1+1,size(unwrapparams.xM,2),nfile],'uint8');
for i = 1:nfile
    load(fullfile(snapdir,sprintf('%05d_%s',i,rfn)))
    snaps(:,:,i) = gantry_processim(rgb2gray(fr),unwrapparams,crop);
end

save(fullfile(g_dir_routes,rfn),'-append','snaps')