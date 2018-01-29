% function SkyLine_Hand(s) 
% 
% this function takes a list of files in a structure s such as you would
% get by doing:
%       s = dir('Files*.mat')
% or
%       s = dir('Files*.jpg')
% 
% and then makes a binary mask which is just the ground. It does 3 stages
% 
% 1. allows you to pick a threshold of sky/not-sky
% 
% 2. makes a mask of this which is only one object connected to the ground. 
% To do this it assumes that if the image is viewed as an image in matlab 
% that the sky is at the top and the ground at the bottom. This means that
% viewed as a matrix the sky is at row 1, while ground is the highest row
% if the images are unwrapped it means they have been unwrapped from the
% sky out(ie the mirroe is resting in the floor facing up)
% if this is not the case you'll need to reverse the images
% 
% 3. It plots and returns a 1-d skyline
% 
% I'll explain the functions within the sub-functions
% 
% if the end of the file name is .mat it loads the file and assumes the 
% there is a grey-scale image in unw_bw and (optionally) an rgb image in
% unw_im. This is how the unwrapping function unwrappingFitting.m outputs
% them
% 
% All other files it tries to load as images via imread
% 
% this is a fairly rough function as I am still using it so any problems
% email me

function andy_skyline(whd,glob,imfun,overwrite)
if nargin < 4
    overwrite = false;
end
if nargin < 3 || isempty(imfun)
    imfun = @deal;
end
if nargin < 2 || isempty(imfun)
    glob = '*.png';
end
if nargin < 1 || isempty(whd)
    whd = g_imdb_choosedb;
end
s = dir(fullfile(whd,glob));

t=[];
% opt=1;
dontcheck=0;

[~,shortwhd] = fileparts(whd);
savedir = fullfile(g_dir_imdb,['skyline_' shortwhd]);
if ~exist(savedir,'dir')
    mkdir(savedir);
end
for j=1:length(s)
    fn=fullfile(whd,s(j).name);
    fnew=fullfile(savedir,s(j).name(1:end-4));
    alreadyexists = exist([fnew '.mat'],'file');
    if alreadyexists
        if overwrite
            warning([fnew ' already processed, overwriting'])
        else
            warning([fnew ' already processed -- skipping'])
            continue
        end
    end
    
    newim = imfun(imread(fn));

    % This bit goes through each file one-by-one and then lets you
    % raise or lower the threshold by hand
    % it can also allow you to get rid of esections of sky (eg due to
    % lens flare but I haven't written full instructions for this
    [bina,t,skyl,dontcheck,quit]=binaryimage(newim,[],t,dontcheck,[]);
    if quit
        disp('Quitting')
        return
    end

    % this bit gets a single object connected to the ground
    % see help for this subfunction for how it works
    bina1=GetOneObjectBinary(bina);
    skyl=GetSkyLine(bina1);
    PlotIms(newim,[],bina,bina1,skyl);
    close all

    newim(~bina1) = 255;
    fprintf('Saving %s.*...\n',fnew);
    save(fnew,'bina','bina1','skyl','t')
    imwrite(newim,[fnew '.png']);
end

function PlotIms(im,imrgb,bina,bina1,skyl)
subplot(3,1,1),
if(isempty(imrgb))
    imagesc(im),
else
    imagesc(imrgb)
end
hold on;plot(skyl,'r'); hold off
axis image
colormap gray

subplot(3,1,2)
nosky=double(im).*bina1;
imagesc(nosky),
hold on;plot(skyl,'r'); hold off
axis image
colormap gray

subplot(3,1,3)
imagesc(double(im).*bina),
hold on;plot(skyl,'r'); hold off
axis image
colormap gray

% this gets a skyline from a binary image. It returns a high and a low
% skyline. The highest skyline is the highest point in each column which is
% ground. The low skyline is the lowest point in ecah column which is
% ground
function[skyl_hi,skyl_lo]= GetSkyLine(bina)
for i=1:size(bina,2)
    skyl_lo(i)=double(find([0;bina(:,i)]==0,1,'last'));
    hi = double(find([bina(:,i)]==1,1,'first'));
    if isempty(hi)
        skyl_hi(i) = 1;
    else
        skyl_hi(i) = hi;
    end
end

% this bit gets a single object assumed to be connected to the ground. 
% It does this by first filling any holes (ie non-sky object surrounded by 
% ground)in the image, then picks out the object which contains the 
% ground pixel in the mask closest to the ground and gets rid of all other
% objects (It also does a check that this is the bigges object) 
%
% it then sets the lowest row of the image as a ground pixel.
% as well as the side pixels. It then fills any holes again
function[bina1]=GetOneObjectBinary(bina)

bina(end,:)=1;
bina=double(bwfill(bina,'holes'));
bl=bwlabel(bina);
objnum=bl(end,1);
bina1=double(bl==objnum);

% leave only the biggest object
S=regionprops(bl,'Area');
[~,objnum2]=max([S.Area]);
check=[objnum objnum2];

m1=find(bina1(:,1)==1,1,'first');
bina1(m1:end,1)=1;
m2=find(bina1(:,end)==1,1,'first');
bina1(m2:end,end)=1;
bina1=double(bwfill(bina1,'holes'));


function[bina,t,skyl,dontcheck,quit]=binaryimage(im,imrgb,t,dontcheck,rgbopt)
quit = false;
if false %(rgbopt==1)
    d=imrgb(:,:,3);
    pim=imrgb;
else
    d=im;
    pim=im;
end
if((nargin<2)||isempty(t))
    t=round(median(d(:)));
end
while 1
    bina=double(d<t);
    skyl=GetSkyLine(bina);
    if(dontcheck==1)
        return;
    end
    
    bina1=GetOneObjectBinary(bina);
    skyl=GetSkyLine(bina1);
    PlotIms(im,imrgb,bina,bina1,skyl);
    
    title(['threshold = ' int2str(t) '; up/down to increase/decrease; t set threshold'])
    xlabel('k keyboard; enter ok; c stop checking')
    try
        [~,~,b]=ginput(1);
    catch
        quit = true;
        return
    end
    if(isempty(b))
        break;
    elseif(isequal(b,'c'))
        dontcheck=1;
        break;
    elseif(isequal(b,'t'))
        t=ForceNumericInput(['threshold = ' int2str(t) '; enter new one: '],0,1);
    elseif(isequal(b,'k'))
        keyboard;
    elseif(b==30)
        t=t+1;
    elseif(b==31)
        t=t-1;
    end
end

function[newd,newb]=RegionCol(d,c,b)

figure(2)
imagesc(d);
newd=d;newb=b;
[x,y]=ginput;
x=round([x;x(1)]);
y=round([y;y(1)]);
gs=diff(y)./diff(x);
ps=[];
for i=1:(length(x)-1)
    if(x(i)==x(i+1)) ps=[ps;x(i:i+1) y(i:i+1)];
    else
       if(x(i)<x(i+1)) xs=[0:x(i+1)-x(i)]';
       else xs=[0:-1:x(i+1)-x(i)]';
       end
       ys=round(gs(i)*xs);
       ps=[ps;xs+x(i) ys+y(i)];
    end
end

[h,w]=size(d);
x1=max(1,min(x));
x2=min(w,max(x));
for xp=x1:x2
    is=find(ps(:,1)==xp);
    ymin=max(1,min(ps(is,2)));
    ymax=min(w,max(ps(is,2)));
    newd(ymin:ymax,xp)=c;
    newb(ymin:ymax,xp)=mod(c+1,2)*255;
end
imagesc(newd)

    


function[rca,es1,ys,es2]=RotCA(skylines,goal,mini,mini2,Tol)
if(nargin<5) Tol=45; end;

[ys,is]=VisCompSkylines(skylines,goal);
s=find(abs(ys)<=Tol);
[es1,ns]=min([mini-1;361-mini]);ms=find(ns==2);es1(ms)=es1(ms)*-1;
r=find(abs(es1)<=Tol);
[es2,ns]=min([mini2-1;361-mini2]);ms=find(ns==2);es2(ms)=es2(ms)*-1;
o=find(abs(es2)<=Tol);
rca=[length(r) length(s) length(o)];

function[il,il2,skyls]=eqheight(newim,imrgb,skyc)

v=1;
wid=size(newim,2);
d=double(imrgb(:,:,3)-imrgb(:,:,2));

for i=1:wid
    t=120;
    sp=find(imrgb(:,i,3)<t,1,'first');
    while(isempty(sp))
        t=t+20;
        sp=find(imrgb(:,i,3)<t,1,'first');
    end
    i2(i)=find(d(sp:end,i)<=0,1,'first')+sp-1;
end
skyl=i2+1;%v(2)-v(1)-i2;
%skyline
sms=round(medfilt1(skyl,25));
bads=find(abs(sms-skyl)>100);
skyls=skyl;
skyls(bads)=sms(bads);
if(v>1) skyls=medfilt1(skyls,v); end;
%

[skyl,t]=AdjustThreshold(imrgb);
skyls=AdjustSkyl(skyl,imrgb,v)

if(nargin<3)
    skym=newim(1:min(skyls),:);
    skyc=median(double(skym(:)));
end

il=double(newim);
il2=il;
for k=1:wid il(1:skyls(k),k)=skyc; end

for k=1:wid
    il2(1:skyls(k),k)=1;%skyc;
    il2(skyls(k)+1:end,k)=0;
end
figure(1),imagesc(imrgb), hold on,
plot(1:wid,skyls,'r','LineWidth',2),hold off
axis image
figure(2),imagesc(il2),hold on
plot(1:wid,skyls,'k','LineWidth',2),hold off


function[sl,t]=AdjustThreshold(imrgb,t)

v=1;
wid=size(imrgb,2);
d=double(imrgb(:,:,3)-imrgb(:,:,2));

% for i=1:wid
%     sp=find(imrgb(:,i,3)<t,1,'first');
%     while(isempty(sp))
%         t=t+20;
%         sp=find(imrgb(:,i,3)<t,1,'first');
%     end
%     i2(i)=find(d(sp:end,i)<=0,1,'first')+sp-1;
% end
% skyl=i2+1;
if(nargin<2) t=max(max((imrgb(:,:,2)))); end;
while 1
    for i=1:wid
        sp=find(imrgb(:,i,2)>t,1,'first');
        tm=t;
        while(isempty(sp))
            tm=tm-1;
            sp=find(imrgb(:,i,2)>tm,1,'first');
        end
        sl(i)=sp;
    end
    sl=sl+2;
    figure(1),imagesc(imrgb), hold on,
    plot(sl,'r','LineWidth',2),hold off
    axis image
    title(['threshold = ' int2str(t) '; up to increase, down to decrease; # to set; c to end'])
    [x,y,b]=ginput(1);
    if(isequal(b,'c')) break;
    elseif(b==30) t=t+1;
    elseif(b==31) t=t-1;
    end
end

function[sl]=AdjustSkyl(sl,imrgb,v)
w=size(imrgb,2);
while 1
    figure(1),imagesc(imrgb), hold on,
    plot(sl,'r','LineWidth',2),hold off
    axis image
    title('c to end or click 2 points and sky will be joined linearly')
    [x,y,b]=ginput(2);
    if(isequal(char(b(1)),'c')) break;
    elseif(length(x)==2)
        x=max([1;1],round(x));
        x=min([w;w],round(x));
        y=round(y);
        a1=y(1);% newi(x(1));
        a2=y(2);% newi(x(2));
        sl(x(1):x(2))=round(a1+(a2-a1)/(x(2)-x(1))*[0:(x(2)-x(1))]);
        if(v>1) sl=round(medfilt1(sl,v)); end
    end
end