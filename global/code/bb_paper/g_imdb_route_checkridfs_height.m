
clear
close all

% x = 2000;
% y = 1400;
x = 1600;
y = 1500;

nth = 360;
improc = '';
forcegen = false;

res = 90;
shortwhd='imdb_2017-02-09_001'; % open, new boxes
whd = fullfile(g_dir_imdb,shortwhd);
zht = 0:100:500; % +50mm
routenum = 3;

arenafn = 'arena2_pile';

crop = load('gantry_cropparams.mat');
bestsnap = NaN(length(zht),1);
myridfs = NaN(nth,length(zht));
for i = 1:length(zht)
    [imxi,imyi,heads,whsn,err,nearest,dist,snx,sny,snth,errsel,p,isnew,allwhsn,ridfs] = g_imdb_route_getrealsnapserrs3d(shortwhd,arenafn,routenum,res,zht(i),false,improc,forcegen);
    
    xi = find(x==p.xs);
    yi = find(y==p.ys);
    sel = find(xi==imxi & yi==imyi);
    bestsnap(i) = whsn(sel);
    myridfs(:,i) = shiftdim(ridfs(sel,:,bestsnap(i)));
end

%%
figure(1);clf
plot(myridfs)
axis tight
legend(num2str(zht'))