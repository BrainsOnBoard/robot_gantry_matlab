function g_live_compareimdb_snapmap
% clear

% p.arenafn = [];

snapweighting = 'wta'; %{'wta','norm5','[1,0.75,0.25]'};
snapweightinglabel = 'wta'; % {'winner-take-all','normalised (n=5)','fixed (n=3)'};
fov = 180;
figsz = [30 15];
dosave = false;

zi = 3;

nth = 360;

[imdir,imdirshort,imlabel] = imdb_choosedb3d;
load(fullfile(imdir,'im_params.mat'));

whroute = input('Enter which route num: ');

[heads,minval,whsn,rd]=g_live_compareimdb_getdata(p.arenafn,whroute,imdirshort,zi,snapweighting,nth,fov);

