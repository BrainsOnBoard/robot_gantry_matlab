function gantry_configurecirc
%   RAL_CONFIGURECIRC Configure alignment of panoramic images for rotation etc.
%   Follow the instructions and centre the circle on the panoramic image.

% fn = '100_0007.MP4';
% dat = mmread(fullfile(pwd,fn),1);
% im = rgb2gray(dat.frames.cdata);
whd = g_imdb_choosedb;
d = dir(fullfile(whd,'im_*_*.mat'));
load(fullfile(whd,d(1).name));
% fr = rgb2gray(fr);

% cam = ipcam('http://172.16.0.254:9176');
% im = snapshot(cam);
% delete(cam);

matfile = fullfile(mfiledir,'gantry_centrad.mat');
% if exist(matfile,'file')
%     load(matfile)
%     origimsz = [size(fr,1),size(fr,2)];
% %     trimv = round(origimsz.*(2.*cent([2 1])-1));
% %     fr = ral_trimim(fr,trimv);
%     [x,y] = pol2cart(linspace(0,2*pi,1000),outrad*(max(origimsz)-1));
%     figure(1);clf
%     imshow(fr)
% %     colormap gray
%     axis equal
%     hold on
%     plot(x+size(fr,2)/2-0.5,y+size(fr,1)/2-0.5)
% 
%     if confirmyn('Is this circle centred OK? (y/n) ')
%         return
%     end
% end

% fr = 1-im2double(repmat(fr,[1 1 3]));

% figure(1)
[cent,outrad,imsz]=FitCircle2(fr);
inrad = [];
pwadd = 1;
figure(1)
while true
    clf
    imshow(fr)
    hold on
    MyCircleLocal(cent(1),cent(2),outrad);
    if ~isempty(inrad)
        MyCircleLocal(cent(1),cent(2),inrad);
    end
    title('click inner ring')
    [x,y,but]=ginput(1);
    if isempty(but) && ~isempty(inrad)
        break;
    else
        switch but
            case 1
                inrad = hypot(cent(1)-x,cent(2)-y);
            case 30 % up
                cent(2) = cent(2)-pwadd;
            case 31 % down
                cent(2) = cent(2)+pwadd;
            case 28 % left
                cent(1) = cent(1)-pwadd;
            case 29 % right
                cent(1) = cent(1)+pwadd;
            case 93 % ]
                inrad = inrad+pwadd;
            case 91 % [
                inrad = max(inrad-pwadd,1);
        end
    end
end

% cent = (cent-0.5)./(imsz([2 1])-1);
% outrad = outrad./(unique(imsz)-1); % gives error if not square image
% inrad = inrad./(unique(imsz)-1); % gives error if not square image
save(matfile,'cent','outrad','inrad','imsz');

ndeg = input('enter fov between top and bottom (deg): ');

si=size(fr);
[X,Y]=meshgrid(1:si(2),1:si(1));

% np=90;
np=720;
p=2*pi/np;

% these are the thetas: depending on the camera may need to change this
% as the -p specifies which way round one unwraps and the start_t specifies
% which starting position to use
% ts=pi:-p:(-pi+p);
ts=0:-p:-(2*pi-p);
start_t=pi/2;
ts=ts+start_t;
d=(outrad-inrad)/(ndeg/(360/np));
rads=(inrad+d):d:(outrad);

xM=[];yM=[];
for r=rads
    [xs,ys]=pol2cart(ts,r);
    xM=[xM; xs];
    yM=[yM; ys];
end
xM=xM+cent(1);
yM=yM+cent(2);

unwrapparams = struct('X',X,'Y',Y,'xM',xM,'yM',yM);
save(matfile,'unwrapparams','-append');%,'subsampfact','cent','');

function [c,rad,imsz] = FitCircle2(im,sp,axw)
imsz = [size(im,1),size(im,2)];
clf
imagesc(im);
if(nargin==3) axis(axw); end;
axis equal;
hold on;
if(nargin<2)
    [c,rad]=GetStartPoint;
else
    c=sp(1:2);
    rad=sp(3);
    t=pi/2;
end
MyCircleLocal(c(1),c(2),rad,'r');
plot(c(1),c(2),'r.');
hold off;

[c,rad]=AdjustCircle(im,c,rad);

function[c,rad]=AdjustCircle(im,c,rad,str)
imagesc(im)
axis equal
if(nargin>3)
    xlabel(str);
end
hold on;
col='b';
if(nargin>2)
    h=MyCircleLocal(c,rad,col);
    h=[h;plot(c(1),c(2),[col 'x'],'MarkerSize',10)];
else
    h=[];    
end
pwadd=1; %0.25;
while 1
    r=rad*1.2;
    axis([c(1)-r c(1)+r c(2)-r c(2)+r])
    title('click position; cursors move x; [ or ]: change radius x; x set x; return end')
    [x,y,b]=ginput(1);
    if(isempty(x))
        delete(h);
        break;
    elseif(b==30) % up cursor
        c(2)=c(2)-pwadd;
    elseif(b==31) % down cursor
        c(2)=c(2)+pwadd;
    elseif(b==28) % left cursor
        c(1)=c(1)-pwadd;
    elseif(b==29) % right cursor
        c(1)=c(1)+pwadd;
    elseif(b==93) % right bracket ]
        rad=rad+pwadd;
    elseif(b==91) % left bracket [
        rad=max(rad-pwadd,1);
    elseif(b==120) % x
        pwadd=input(['x = ' num2str(pwadd) '; enter new value: ']);
    else
        c=[x y];
    end
    delete(h);
    h=MyCircleLocal(c,rad,col);
    h=[h;plot(c(1),c(2),[col 'x'],'MarkerSize',10)];
end
hold off;


function[c,rad]=GetStartPoint
title('Click 7 points on the radius')
[x,y]=ginput(7);
% solve
abc=pinv([x,y,ones(size(x))])*(x.^2+y.^2);

c=[abc(1)/2,abc(2)/2];
rad=mean(sqrt((x-c(1)).^2+(y-c(2)).^2));

% rad=sqrt((abc(1)/2)^2+(abc(2)/2)^2-abc(3));

function im1=resizeImage(im,acuity)
% acuity is in degrees i.e. acuity=4 -> each pixel is 4 degrees,
% acuity = 0.2 ->5 pixels /degree
if nargin==1
    acuity=1;
end
% check whether colour or black and white
[a,b,c]=size(im);
if c==1
    % black and white
    B=double(im);
    [h,w]=size(im);
    block_sz=acuity*round(w/360);

    % make sure the dimensions are whole numbers

    max_h=floor(h/block_sz)*block_sz;
    max_w=floor(w/block_sz)*block_sz;

    B=B(1:max_h,1:max_w);

    fun=@(x) mean(x(:));

    im1=blkproc(B,[block_sz block_sz],fun);
else
    %colour
    R=double(im(:,:,1));
    B=double(im(:,:,2));
    G=double(im(:,:,3));
    [h,w]=size(R);
    block_sz=acuity*round(w/360);

    % make sure the dimensions are whole numbers

    max_h=floor(h/block_sz)*block_sz;
    max_w=floor(w/block_sz)*block_sz;

    R=R(1:max_h,1:max_w);
    B=B(1:max_h,1:max_w);
    G=G(1:max_h,1:max_w);
    % anonymous function
    fun=@(x) mean(x(:));

    im1(:,:,1)=uint8(blkproc(R,[block_sz block_sz],fun));
    im1(:,:,2)=uint8(blkproc(B,[block_sz block_sz],fun));
    im1(:,:,3)=uint8(blkproc(G,[block_sz block_sz],fun));
end

% function[lhdl] = MyCircleLocal(x,y,Rad,col,NumPts,fillc)
%
% Function draws circles of radius Rad(i) at x(:,i),y(:,i). 
% col is colour, NumPts the number of points to draw the circle
% defaults are blue and 50 and fills it if fillc = 1 (default 0)
%
% if x is a 2D row vector, it uses x as position and other parameters 
% shift across one eg y is rad
%
% function returns ldhl, handles to the lines
function[lhdl] = MyCircleLocal(x,y,Rad,col,NumPts,fillc)
ho=ishold;
if(size(x,2)==2)
    if(nargin<5) 
        fillc=0;
    else
        fillc=NumPts;
    end
    if((nargin<4)||isempty(col)) 
        NumPts=50;
    else
        NumPts=col;
    end;
    if(nargin<3) 
        col = 'b';
    else
        col=Rad;
    end;
    Rad=y;
    y=x(:,2);
    x=x(:,1);
else
    if(nargin<6) 
        fillc=0; 
    end;
    if((nargin<5)||isempty(NumPts)) 
        NumPts=50; 
    end;
    if(nargin<4) 
        col = 'b'; 
    end;
end

Thetas=0:2*pi/NumPts:2*pi;
lhdl=zeros(length(Rad));
if(size(col,1)==1)
    for i=1:length(Rad)
        [Xs,Ys]=pol2cart(Thetas,Rad(i));
        if(fillc) 
            fill(Xs+x(i),Ys+y(i),col);
            hold on;
        end
        lhdl(i)=plot(Xs+x(i),Ys+y(i),'Color',col);
        % THIS ERROR LOOKS TO BE A VERSION CHANGE: BELOW FOR NEW VERSIONS
%         lhdl(i)=plot(Xs+x(i),Ys+y(i),col);
        hold on
    end
else
    for i=1:length(Rad)
        [Xs,Ys]=pol2cart(Thetas,Rad(i));
        if(fillc) 
            fill(Xs+x(i),Ys+y(i),col(i,:));
            hold on;
        end
        lhdl(i)=plot(Xs+x(i),Ys+y(i),'Color',col(i,:));
        % THIS ERROR LOOKS TO BE A VERSION CHANGE: BELOW FOR NEW VERSIONS
%         lhdl(i)=plot(Xs+x(i),Ys+y(i),col(i,:));
        hold on
    end
end
if(~ho) 
    hold off; 
end;
