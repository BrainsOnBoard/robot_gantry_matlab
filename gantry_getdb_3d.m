function gantry_getdb_3d

p = load('arenadim.mat');

p.dummy = false;

p.zclear = 50;
p.zoffs = 50;
p.objgridac = 10; % mm
p.headclear = 150; % clearance for head (camera) in mm
p.arenafn = []; %'arena1_boxes_3d.mat';

headcleari = ceil(p.headclear/p.objgridac);

objmap = gantry_getobjmatrix_3d(p.arenafn,p.objgridac);
% figure(1);clf
% imshow(flipud(objtf))
% return

oxs = p.objgridac*(0:size(objmap,2));
oys = p.objgridac*(0:size(objmap,1));

p.maxV = [240;240;151];
p.maxA = [20;20;20];
acuity = 1;
% Gantry(debug, homeGantry, disableZ, acuity, maxV, maxA)
if p.dummy
    disp('RUNNING IN DUMMY MODE - not moving gantry')
else
    g = alexGantry(false,false,false,acuity,p.maxV,p.maxA);
end

p.imsep = 100; % mm
p.xs = 0:p.imsep:p.lim(1);
p.ys = 0:p.imsep:p.lim(2);
p.zs = 0:p.imsep:500; %p.lim(3); % +p.zoffs mm
p.imsz = [576,720,3];
imdirrt = fullfile(mfiledir,['imdb3d_' datestr(now,'yyyy-mm-dd') '_']);

dind = 1;
while true
    p.imdir = sprintf('%s%03d',imdirrt,dind);
    if ~exist(fullfile(p.imdir,'im_params.mat'),'file');
        break;
    end
    dind = dind+1;
end
if ~p.dummy && ~exist(p.imdir,'dir')
    mkdir(p.imdir)
end

nim = length(p.xs)*length(p.ys)*length(p.zs);
fprintf('getting image database\n%dx%dx%d (=%d) ims\nx: [%g %g]\ny: [%g %g]\nz: [%g %g]\n\n', ...
    length(p.ys),length(p.xs),length(p.zs),nim,p.xs(1),p.xs(end),p.ys(1),p.ys(end),p.zs(1),p.zs(2))

if ~p.dummy
    save(fullfile(p.imdir,'im_params.mat'),'p')
    
    g.homeGantry(false);
end

lastx = 0;
lasty = 0;
lastz = 0;
cim = 1;
try
    tic
    startprogbar(1,nim,'getting image db',true)
    for xi = 1:length(p.xs)
        curx = p.xs(xi);
        
        if mod(xi,2)
            cys = 1:length(p.ys);
            ysgn = 1;
        else
            cys = length(p.ys):-1:1;
            ysgn = -1;
        end
        for yi = cys
            cury = p.ys(yi);
            
            if xi==1 && yi==1
                czs = 1:length(p.zs);
                minghtpath = 0;
            else % then work out if going to collide
                
                %                 fprintf('x: %g, %g\ny: %g, %g\n',lastx,curx,lasty,cury)
                
                %                 figure(1);clf
                %                 subplot(1,2,1)
                %                 imshow(objtf)
                %                 subplot(1,2,2)
                %                 imshow(headpath)
                
                oendx = find(curx<=oxs,1)-1;
                oendy = find(cury<=oys,1)-1;
                
                ostx = find(lastx>=oxs,1,'last');
                osty = find(lasty>=oys,1,'last');
                yi1 = min(length(oys)-1,max(1,osty-ysgn*headcleari));
                yi2 = min(length(oys)-1,max(1,oendy+ysgn*headcleari));
                xi1 = min(length(oxs)-1,max(1,ostx-headcleari));
                xi2 = min(length(oxs)-1,max(1,oendx+headcleari));
                
                % minimum operating height for gantry over current path
                minghtpath = max(max(objmap(yi1:sign(yi2-yi1):yi2,xi1:sign(xi2-xi1):xi2)));
                if minghtpath > 0
                    minghtpath = minghtpath-p.zoffs+p.zclear;
                end
                
                % minimum operating height for gantry at dest pos
                minghtdest = max(max(objmap(max(1,oendy-headcleari):min(length(oys)-1,oendy+headcleari), ...
                                            max(1,oendx-headcleari):min(length(oxs)-1,oendx+headcleari))));
                if minghtdest > 0
                    minghtdest = minghtdest-p.zoffs+p.zclear;
                end
                
                whhigh = p.zs >= minghtdest; % which zs are higher than the thing at dest pos?
                czs = find(whhigh);
                if abs(p.zs(czs(end))-lastz) < abs(p.zs(czs(1))-lastz) % if nearer top than bottom, then reverse z order
                    czs = czs(end:-1:1);
                end
                cim = cim+sum(~whhigh); % skip "lows"
            end
            
            for zi = czs
                fprintf('image %d/%d\n',cim,nim)
                
                curz = p.zs(zi);
                if (curx~=lastx || cury~=lasty) && lastz < minghtpath % then raise gantry
                    disp('retracting head')
                    movetopoint(lastx,lasty,minghtpath)
                    if curz < minghtpath
                        movetopoint(curx,cury,minghtpath) % make sure going over object
                    end
                end
                movetopoint(curx,cury,curz);
                
                if p.dummy
                    disp('(would be getting frame now...)')
                else
                    fr = g.getRawFrame;
                    save(fullfile(p.imdir,sprintf('im_%03d_%03d_%03d.mat',xi,yi,zi)),'fr')
                end
                
                lastx = curx;
                lasty = cury;
                lastz = curz;
                
                cim = cim+1;
                
                if progbar
                    if ~p.dummy
                        delete(g)
                    end
                    return
                end
            end
        end
    end
    ttot = toc;
    fprintf('Time: %gs (%gs per image)\n',ttot,ttot/nim)
    
    if ~p.dummy
        g.homeGantry(false);
        delete(g)
    end
catch ex
    if ~p.dummy
        delete(g)
    end
    rethrow(ex)
end

    function movetopoint(x,y,z)
        if all([x,y,z]==0) || x~=lastx || y~=lasty || z~=lastz
            if p.dummy
                fprintf('Moving to (%g,%g,%g)\n',x,y,z)
                %     pause(0.25)
            else
                g.moveToPoint([x;y;z]);
            end
        else
            disp('same pos, not moving gantry')
        end
    end

end