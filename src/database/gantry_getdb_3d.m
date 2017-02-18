function gantry_getdb_3d(olddate,oldind)
if nargin
    if isempty(olddate)
        olddate = datestr(now,'yyyy-mm-dd');
    end
    imdirrt = fullfile(imdbdir,sprintf('imdb3d_%s_%03d',olddate,oldind));
    load(fullfile(imdirrt,'im_params.mat'));
else
    p = load('arenadim.mat');
    
    p.dummy = false;
    
    p.zclear = 50;
    p.zoffs = 50;
    p.objgridac = 10; % mm
    p.headclear = 100; % clearance for head (camera) in mm
    p.arenafn = 'arena2_pile.mat';
    
    p.maxV = [240;240;151];
    p.maxA = [20;20;20];
    
    p.imsep = 100; % mm
    p.xs = 0:p.imsep:p.lim(1);
    p.ys = 0:p.imsep:p.lim(2);
    p.zs = 0:p.imsep:500; %p.lim(3); % +p.zoffs mm
    p.imsz = [576,720,3];
    
    imdirrt = fullfile(imdbdir,['imdb3d_' datestr(now,'yyyy-mm-dd') '_']);
    dind = 1;
    while true
        p.imdir = sprintf('%s%03d',imdirrt,dind);
        if ~exist(fullfile(p.imdir,'im_params.mat'),'file');
            break;
        end
        dind = dind+1;
    end
    
    if ~p.dummy
        if ~exist(p.imdir,'dir')
            mkdir(p.imdir)
        end
        
        save(fullfile(p.imdir,'im_params.mat'),'p')
    end
end

% Gantry(debug, homeGantry, disableZ, acuity, maxV, maxA)
if p.dummy
    disp('RUNNING IN DUMMY MODE - not moving gantry')
else
    g = alexGantry(false,false,false,1,p.maxV,p.maxA);
end

headcleari = ceil(p.headclear/p.objgridac);

objmap = gantry_getobjmatrix_3d(p.arenafn,p.objgridac);
% figure(1);clf
% imshow(flipud(objtf))
% return

oxs = p.objgridac*(0:size(objmap,2));
oys = p.objgridac*(0:size(objmap,1));

nim = length(p.xs)*length(p.ys)*length(p.zs);
fprintf('getting image database\n%dx%dx%d (=%d) ims\nx: [%g %g]\ny: [%g %g]\nz: [%g %g]\n\n', ...
    length(p.ys),length(p.xs),length(p.zs),nim,p.xs(1),p.xs(end),p.ys(1),p.ys(end),p.zs(1),p.zs(2))

if ~p.dummy    
    g.homeGantry(false);
end

if nargin
    nimtoget = nim-length(dir(fullfile(imdirrt,'im_*_*_*.mat')));
else
    nimtoget = nim;
end

lastx = 0;
lasty = 0;
lastz = 0;
cim = 1;
try
    pausefig;
    om3 = repmat(objmap==0,1,1,3);
    tic
    startprogbar(1,nimtoget,'getting image db',true)
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
            
            clf
            oendx = find(curx<=oxs,1)-1;
            oendy = find(cury<=oys,1)-1;
            com3 = om3;
            crow = max(1,oendy-headcleari):min(length(oys)-1,oendy+headcleari);
            ccol = max(1,oendx-headcleari):min(length(oxs)-1,oendx+headcleari);
            collides = objmap(crow,ccol);
            com3(crow,ccol,1) = ~collides;
            com3(crow,ccol,2) = collides;
            com3(crow,ccol,3) = false;
            imshow(flipud(255*com3))
            %             pause(.25)
            
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
                if ~isempty(czs) && abs(p.zs(czs(end))-lastz) < abs(p.zs(czs(1))-lastz) % if nearer top than bottom, then reverse z order
                    czs = czs(end:-1:1);
                end
                cim = cim+sum(~whhigh); % skip "lows"
            end
            
            for zi = czs
                fprintf('image %d/%d (%d, %d, %d)\n',cim,nim,xi,yi,zi)
                cim = cim+1;
                curimfn = fullfile(p.imdir,sprintf('im_%03d_%03d_%03d.mat',xi,yi,zi));
                if exist(curimfn,'file')
                    continue
                end
                
                if ~ishandle(1)
                    waittocontinue
                end
                
                while true
                    try
                        curz = p.zs(zi);
                        if (curx~=lastx || cury~=lasty) && lastz < minghtpath % then raise gantry
                            disp('retracting head')
                            movetopoint(lastx,lasty,minghtpath)
                            if curz < minghtpath
                                movetopoint(curx,cury,minghtpath) % make sure going over object
                            end
                        end
                        movetopoint(curx,cury,curz);
                    catch ex
                        if strcmp(ex.identifier,'gantry:stopped')
                            waittocontinue
                            continue
                        else
                            rethrow(ex)
                        end
                    end
                    
                    break
                end
                
                if p.dummy
                    disp('(would be getting frame now...)')
                else
                    fr = g.getRawFrame;
                    timestamp = now;
                    
                    %                     figure(10);clf
                    %                     imshow(fr)
                    %                     drawnow
                    
                    save(curimfn,'fr','timestamp')
                end
                
                lastx = curx;
                lasty = cury;
                lastz = curz;
                
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
                tmove = tic;
                g.moveToPoint([x;y;z]);
                if toc(tmove) < 0.1
                    error('gantry:stopped','gantry appears to be stopped')
                end
            end
        else
            disp('same pos, not moving gantry')
        end
    end

    function waittocontinue
        input('Press enter to continue.')
        pausefig;
        clf
        oendx = find(curx<=oxs,1)-1;
        oendy = find(cury<=oys,1)-1;
        com3 = om3;
        crow = max(1,oendy-headcleari):min(length(oys)-1,oendy+headcleari);
        ccol = max(1,oendx-headcleari):min(length(oxs)-1,oendx+headcleari);
        collides = objmap(crow,ccol);
        com3(crow,ccol,1) = ~collides;
        com3(crow,ccol,2) = collides;
        com3(crow,ccol,3) = false;
        imshow(flipud(255*com3))
        pause(.4)
    end

end

function pausefig
figure(1);clf
title('close me to pause image grabbing')
end