
clear
arenafn = 'arena1_boxes.mat';
objgridac = 1; % mm

pts = ~gantry_getobjim(arenafn,objgridac);
ipts = find(pts);
[iy,ix] = find(pts);

srci = 1;
dsti = 100;

clickpts = [];
pthi = [];

while true
    figure(1);clf
    imshow(pts)
    hold on
    xl = xlim;
    yl = ylim;
    plot(ix(pthi),iy(pthi),ix(clickpts),iy(clickpts),'b+')
    set(gca,'YDir','normal')
    ylim(yl)
    xlim(xl)
    
    [gx,gy,but] = ginput(1);
    if isempty(but)
        break;
    elseif but==1
        diffs = hypot(iy-gy,ix-gx);
        [~,whii] = min(diffs);
        clickpts(end+1) = whii;
        dsti = clickpts(end);
        srci = clickpts(max(1,length(clickpts)-1));
        curi = srci;
        cpthi = srci;
        while curi~=dsti
%             keyboard
            inbr = find(abs(iy-iy(curi)) <= 1 & abs(ix-ix(curi)) <= 1);
            inbr = inbr(inbr~=curi & ~any(bsxfun(@eq,inbr,cpthi),2));
            dists = hypot(iy(inbr)-iy(dsti),ix(inbr)-ix(dsti));
            [~,I] = min(dists);
            curi = inbr(I);
            cpthi(end+1) = curi; %#ok<SAGROW>
%             plot(ix(pthi),iy(pthi),'r',ix(dsti),iy(dsti),'r+')
        end
        pthi = [pthi,cpthi];
    end
end