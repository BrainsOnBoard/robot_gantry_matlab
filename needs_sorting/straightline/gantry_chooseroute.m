function [clx,cly,cli]=gantry_chooseroute(arenafn,nclicks,objgridac,headclear)
% clear
% arenafn = 'arena1_boxes.mat';
% objgridac = 10; % mm
% headclear = 150;

if nargin < 4 || isempty(objgridac)
    headclear = 150;
end
if nargin < 3 || isempty(objgridac)
    objgridac = 10;
end
if nargin < 2 || isempty(nclicks)
    nclicks = inf;
end
if nargin < 1
    arenafn = [];
end

[objim,badzone,oxs,oys,goxs,goys] = gantry_getbadzoneim(arenafn,objgridac,headclear);

goxs = goxs(:);
goys = goys(:);

ipts = 1:numel(badzone);
[iy,ix] = ind2sub(size(badzone),ipts);

ccnt = 1;
[clx,cly,cli] = deal([]);

load('arenadim.mat')
try
    while true
        figure(1);clf
%         subplot(1,2,1)
        image(goxs,goys,objim)
        axis equal
        set(gca,'YDir','normal')
        ylim([0 lim(2)])
        xlim([0 lim(1)])
        hold on
        
        plot(goxs(cli),goys(cli),goxs(cli),goys(cli),'b+')
        
%         subplot(1,2,2)
%         imshow(clickim)
%         set(gca,'YDir','normal')
        
        [gx,gy,but] = ginput(1);
        if isempty(but)
            break;
        elseif but==1
            [~,whx] = min(abs(oxs-gx));
            [~,why] = min(abs(oys-gy));
            whii = find(oys(why)==goys & oxs(whx)==goxs);
            if ccnt==1
                clickim = false(size(badzone));
                clickim(whii) = true;
            else
                ind = [whii,cli(ccnt-1)];
                clickim = imbwdrawline(false(size(badzone)),ix(ind),iy(ind));
            end
            if ~any(clickim(:) & badzone(:))
                clx(ccnt) = gx;
                cly(ccnt) = gy;
                cli(ccnt) = whii;
                if ccnt < nclicks
                    ccnt = ccnt+1;
                end
            end
        elseif but==3
            ccnt = max(1,ccnt-1);
            cli = cli(1:ccnt);
            clx = clx(1:ccnt);
            cly = cly(1:ccnt);
        end
    end
    clx = round(clx);
    cly = round(cly);
catch ex
    if strcmp(ex.identifier,'MATLAB:ginput:FigureDeletionPause')
        [clx,cly,cli] = deal([]);
    else
        rethrow(ex)
    end
end

if ishandle(1)
    close(1)
end