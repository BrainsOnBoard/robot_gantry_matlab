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

function quit=andy_skyline(shortwhd,glob,imfun,overwrite)
quit = false;
if nargin < 4
    overwrite = false;
end
if nargin < 3 || isempty(imfun)
    imfun = @deal;
end
if nargin < 2 || isempty(glob)
    glob = '*.png';
end
if nargin < 1 || isempty(shortwhd)
    [whd,shortwhd] = g_imdb_choosedb;
else
    whd = fullfile(g_dir_imdb,shortwhd);
end
s = dir(fullfile(whd,glob));

t=[];
% opt=1;
dontcheck=0;

fgsavedir = fullfile(g_dir_imdb,['skyline_' shortwhd]);
if ~exist(fgsavedir,'dir')
    mkdir(fgsavedir);
    copyfile(fullfile(whd,'im_params.mat'),fgsavedir);
end
bgsavedir = fullfile(g_dir_imdb,['skylinebg_' shortwhd]);
if ~exist(bgsavedir,'dir')
    mkdir(bgsavedir);
    copyfile(fullfile(whd,'im_params.mat'),bgsavedir);
end

j = 1;
skip = 0;
x1 = [];
x2 = [];
while j < length(s)
    fnew=fullfile(fgsavedir,s(j).name(1:end-4));
    alreadyexists = exist([fnew '.mat'],'file');
    if alreadyexists
        x1set = varsinmatfile(fnew,'x1');
        if ~x1set || skip~=0 || overwrite
            warning([fnew ' already processed, overwriting'])
            load(fnew);
        else
            warning([fnew ' already processed -- skipping'])
            j = j+1;
            continue
        end
    end
    
    newim = imfun(imread(fullfile(whd,s(j).name)));
    
    fntitle = sprintf('%s %d/%d',s(j).name,j,length(s));
    if alreadyexists && ~x1set
        fntitle = [fntitle ' (x not set)'];
    end

    % This bit goes through each file one-by-one and then lets you
    % raise or lower the threshold by hand
    % it can also allow you to get rid of esections of sky (eg due to
    % lens flare but I haven't written full instructions for this
    [bina,t,skyl,x1,x2,dontcheck,skip,quit]=binaryimage(newim,t,x1,x2,dontcheck,fntitle,alreadyexists);
    if quit
        disp('Quitting')
        quit = true;
        return
    end
    if skip~=0
    	j = max(1,min(length(s),j+skip));
        continue
    end

    % this bit gets a single object connected to the ground
    % see help for this subfunction for how it works
    bina1=GetOneObjectBinary(bina);
    skyl=GetSkyLine(bina1);
    PlotIms(newim,bina,bina1,skyl,fntitle,alreadyexists);

    skyl=g_bb_cap_skyl(skyl,x1,x2,size(newim,1));
    if isa(newim,'double')
        white = 1;
    else
        white = 255;
    end
    sel = bsxfun(@lt,(1:size(newim,1))',skyl);
    newim2 = newim;
    newim(sel) = white;
    fprintf('Saving %s.*...\n',fnew);
    save(fnew,'bina','bina1','skyl','t','x1','x2')
    imwrite(newim,[fnew '.png']);
    
    newim2(~sel) = white;
    imwrite(newim2,fullfile(bgsavedir,[s(j).name(1:end-4) '.png']));
    
    j = j+1;
end

function PlotIms(im,bina,bina1,skyl,fn,alreadyexists)
subplot(3,1,1),
imagesc(im),
hold on;plot(skyl,'r'); hold off
axis image
colormap gray
h=title(fn,'Interpreter','none');
if alreadyexists
    set(h,'Color','r')
end

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


function[bina,t,skyl,x1,x2,dontcheck,skip,quit]=binaryimage(im,t,x1,x2,dontcheck,fn,alreadyexists)
quit = false;
skip = 0;
d=im;
if((nargin<2)||isempty(t))
    t=round(median(d(:)));
end
while 1
    bina=double(d<t);
    skyl=GetSkyLine(bina);
    if(dontcheck==1)
        return
    end
    
    wd = size(im,2);
    bina1=GetOneObjectBinary(bina);
    skyl=GetSkyLine(bina1);
    % only consider objects within this x range
    if ~isempty(x1)
        skyl = g_bb_cap_skyl(skyl,x1,x2,size(im,1));
    end
    PlotIms(im,bina,bina1,skyl,fn,alreadyexists);
    
    title(['threshold = ' int2str(t) '; up/down to increase/decrease; t set threshold'])
    xlabel('k keyboard; enter ok; c stop checking')
    
    subplot(3,1,1)
    if ~isempty(x1)
        hold on
        plot([x1 x1],[1 size(im,1)],'g',[x2 x2],[1 size(im,1)],'g');
    end
    try
        [xx,~,b]=ginput(1);
    catch
        quit = true;
        return
    end
    if isempty(b)
        return
    end
    switch b
        case 1 % left click
            xx = max(1,min(wd,round(xx)));
            if isempty(x1)
                title(sprintf('Starting at %d, click on end',xx));
                b2 = NaN;
                while b2~=1
                    [xx2,~,b2] = ginput(1);
                    if isempty(b2)
                        continue
                    end
                end
                x1 = xx;
                x2 = max(1,min(wd,round(xx2)));
            elseif abs(azdiff(x1,xx,wd)) <= abs(azdiff(x2,xx,wd))
                x1 = xx;
            else
                x2 = xx;
            end
        case 3 % right click
            xx = max(1,min(wd,round(xx)));
            df = azdiff(xx,[x1 x2],wd);
            [~,I] = min(abs(df));
            x1 = normaz(x1+df(I),wd);
            x2 = normaz(x2+df(I),wd);
        case 'a'
            x1 = normaz(x1+5,wd);
            x2 = normaz(x2-5,wd);
        case 'd'
            x1 = normaz(x1-5,wd);
            x2 = normaz(x2+5,wd);
        case 8 % backspace
            x1 = [];
            x2 = [];
        case ' '
            return
        case 'c'
            dontcheck=1;
            close all
            return
        case 't'
            t = ForceNumericInput(['threshold = ' int2str(t) '; enter new one: '],0,1);
        case 'k'
            keyboard
        case 28 % left
            skip = -1;
            return
        case 29 % right 
            skip = 1;
            return
        case 30 % up
            t=t+1;
        case 31 % down
            t=t-1;
        case 'w'
            t=t+5;
        case 's'
            t=t-5;
    end
end

function d=azdiff(a,b,wd)
d = round(circ_dist(a*2*pi/wd,b*2*pi/wd)*wd/(2*pi));
