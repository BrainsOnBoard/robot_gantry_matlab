function gantry_getdb_objs
clear

p = load('arenadim.mat');

p.zclearht = 700;
p.objgridac = 10; % mm
p.headclear = 150; % clearance for head (camera) in mm
p.arenafn = []; %'arena1_boxes.mat';

headcleari = ceil(p.headclear/p.objgridac);

objtf = gantry_getobjmatrix(p.arenafn,p.objgridac);

% figure(1);clf
% imshow(flipud(objtf))
% return

oxs = p.objgridac*(0:size(objtf,2));
oys = p.objgridac*(0:size(objtf,1));

p.maxV = [240;240;151];
p.maxA = [20;20;20];
acuity = 1;
% Gantry(debug, home_gantry, disableZ, acuity, maxV, maxA)
g = g_control_object(false,false,false,acuity,p.maxV,p.maxA);

p.imsep = 100; % mm
p.xs = 0:p.imsep:p.lim(1);
p.ys = 0:p.imsep:p.lim(2);
p.zht = 250; % +50mm
p.imsz = [576,720,3];
imdirrt = fullfile(mfiledir,['imdb_' datestr(now,'yyyy-mm-dd') '_']);

dind = 1;
while true
    p.imdir = sprintf('%s%03d',imdirrt,dind);
    if ~exist(fullfile(p.imdir,'im_params.mat'),'file');
        break;
    end
    dind = dind+1;
end
if ~exist(p.imdir,'dir')
    mkdir(p.imdir)
end

nim = length(p.ys)*length(p.xs);
fprintf('getting image database\n%dx%d (=%d) ims\nx: [%g %g]\ny: [%g %g]\n\n', ...
    length(p.ys),length(p.xs),nim,p.xs(1),p.xs(end),p.ys(1),p.ys(end))

save(fullfile(p.imdir,'im_params.mat'),'p')
isretracted = false;

g.home_gantry(false);
lastx = 0;
lasty = 0;
try
    cim = 1;
    tic
    startprogbar(1,nim,'getting image db',true)
    for xi = 1:length(p.xs)
        if mod(xi,2)
            cys = 1:length(p.ys);
            ysgn = 1;
        else
            cys = length(p.ys):-1:1;
            ysgn = -1;
        end
        for yi = cys
            fprintf('image %d/%d\n',cim,nim)
            curx = p.xs(xi);
            cury = p.ys(yi);
            movegetframe = true;
            if xi>1 || yi>1 % work out if going to collide
                
                %                 fprintf('x: %g, %g\ny: %g, %g\n',lastx,curx,lasty,cury)
                
                %                 figure(1);clf
                %                 subplot(1,2,1)
                %                 imshow(objtf)
                %                 subplot(1,2,2)
                %                 imshow(headpath)
                
                oendx = find(curx<oxs,1)-1;
                oendy = find(cury<oys,1)-1;

                if ~isretracted
                    ostx = find(lastx>=oxs,1,'last');
                    osty = find(lasty>=oys,1,'last');
                    yi1 = min(length(oys)-1,max(1,osty-ysgn*headcleari));
                    yi2 = min(length(oys)-1,max(1,oendy+ysgn*headcleari));
                    xi1 = min(length(oxs)-1,max(1,ostx-headcleari));
                    xi2 = min(length(oxs)-1,max(1,oendx+headcleari));
                    headpath = false(size(objtf));
                    headpath(yi1:sign(yi2-yi1):yi2,xi1:sign(xi2-xi1):xi2) = true;
                    
                    if any(headpath(:) & objtf(:)) % then going to collide with object
                        %                     disp('GOING TO COLLIDE WITH OBJECT')
                        disp('retracting head')
                        movetopoint(lastx,lasty,p.zclearht) % retract
                        isretracted = true;
                    end
                end
                
                endtf = false(size(objtf));
                endtf(max(1,oendy-headcleari):min(length(oys)-1,oendy+headcleari), ...
                    max(1,oendx-headcleari):min(length(oxs)-1,oendx+headcleari)) = true;

                %                     subplot(1,3,3)
                %                     imshow(endtf & objtf)
                %                     drawnow

                movegetframe = ~any(endtf(:) & objtf(:));
            end
            
            cim = cim+1;
            
            if movegetframe
                if isretracted % then go over objects before lowering
                    movetopoint(curx,cury,p.zclearht);
                    isretracted = false;
                end
                movetopoint(curx,cury,p.zht);
                
                fr = g.getRawFrame;
                save(fullfile(p.imdir,sprintf('im_%03d_%03d.mat',yi,xi)),'fr')
                
                lastx = curx;
                lasty = cury;
            end
            
            if progbar
                delete(g)
                return
            end
        end
    end
    ttot = toc;
    fprintf('Time: %gs (%gs per image)\n',ttot,ttot/nim)
    
    g.home_gantry(false);
    
    delete(g)
catch ex
    delete(g)
    rethrow(ex)
end

    function movetopoint(x,y,z)
%         fprintf('Moving to (%g,%g,%g)\n',x,y,z)
        %     pause(0.25)
        g.move([x;y;z]);
    end

end