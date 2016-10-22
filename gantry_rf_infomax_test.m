clear

wharena = 'arena1_boxes';
whroute = 1;
whdataset = 1;
imw = 90;

rdir = fullfile(mfiledir,'routedat');
datafn = fullfile(rdir,'data',sprintf('comb_route_%s_%03d_%03d.mat',wharena,whroute,whdataset));
load(datafn)
x = cell2mat(combd.curx);
y = cell2mat(combd.cury);
goalx = cell2mat(combd.goalx);
goaly = cell2mat(combd.goaly);
isbad = logical(cell2mat(combd.isbad));
p = pr.routedat_p;

cdatadir = fullfile(rdir,'data',sprintf('route_%s_%03d_%03d',wharena,whroute,whdataset));

load(fullfile(rdir,sprintf('snaps_route_%s_%03d_fov%03d.mat',wharena,1,pr.fov)));

load(fullfile(rdir,sprintf('infomax_snaps_route_%s_%03d_fov%03d_w%03d.mat',wharena,whroute,pr.fov,imw)))

ths = NaN(size(fovsnaps,3),1);
for i = 1:length(ths)
%     infomax_gethead(im,imsz,weights,angleunit,nth)
    tic
    ths(i) = infomax_gethead(fovsnaps(:,:,i),imsz,W);
    toc
end