function gantry_straightline

p = load('arenadim.mat');
p.crop = load('gantry_cropparams.mat');
load('gantry_centrad.mat','unwrapparams');
p.uw = unwrapparams;

p.zht = 250; % +50mm
p.imsz = [576,720,3];
p.objgridac = 10; % mm
p.headclear = 150; % clearance for head (camera) in mm
p.arenafn = [];
p.startpos = [0;p.lim(2)/2];
p.stepsize = 50;
p.ridfanglim = pi/8;

headcleari = ceil(p.headclear/p.objgridac);

datadir = fullfile(mfiledir,'sl_dat');
if ~exist(datadir,'dir')
    mkdir(datadir)
end

datafnind = 1;
while true
    datafn = fullfile(datadir,sprintf('dat_%s_%03d.mat',datestr(now,29),datafnind));
    if ~exist(datafn,'file')
        break;
    end
    datafnind = datafnind+1;
end
fprintf('Saving data to %s.\n',datafn);
save(datafn,'p');

[objtf,oxs,oys] = gantry_getobjmatrix(p.arenafn,p.objgridac);

p.maxV = [240;240;151];
p.maxA = [20;20;20];
acuity = 1;
% Gantry(debug, homeGantry, disableZ, acuity, maxV, maxA, showvidpreview)
g = alexGantry(false,true,false,acuity,p.maxV,p.maxA,false,false);

try
    curx = 0; cury = 0;
    
    g.moveToPoint([p.startpos;p.zht]);
    snap = getview;
    
    d.nextx = p.startpos(1)+p.stepsize;
    d.nexty = p.startpos(2);
    stepi = 1;
    t=tic;
    while trytomove(d.nextx(end),d.nexty(end))
        d.cview(:,:,stepi) = getview;
        d.head(stepi) = pi2pi(ridfhead(d.cview(:,:,stepi),snap));
        d.bear(stepi) = sign(d.head(stepi))*min(p.ridfanglim,abs(d.head(stepi)));
        [dx,dy] = pol2cart(d.bear(stepi),p.stepsize);
        stepi = stepi+1;
        d.nextx(stepi) = curx+dx;
        d.nexty(stepi) = cury+dy;
        fprintf('head: %g; bear: %g; tox: %g; toy: %g\n',rad2deg(d.head(stepi-1)),rad2deg(d.bear(stepi-1)), ...
                d.nextx(end),d.nexty(end))
    end
    ttot = toc(t);
    fprintf('FINISHED STRAIGHT LINE RUN AFTER %d STEPS (%gs)\n',stepi,ttot)
    save(datafn,'-append','d')
    
    delete(g)
    
catch ex
    delete(g)
    rethrow(ex)
end

    function view=getview
        view = gantry_processim(g.getRawFrame,p.uw,p.crop);
    end

    function succeed=trytomove(movex,movey)
        oendx = find(curx<oxs,1)-1;
        oendy = find(cury<oys,1)-1;
        endtf = false(size(objtf));
        endtf(max(1,oendy-headcleari):min(length(oys)-1,oendy+headcleari), ...
              max(1,oendx-headcleari):min(length(oxs)-1,oendx+headcleari)) = true;

        %                     subplot(1,3,3)
        %                     imshow(endtf & objtf)
        %                     drawnow

        succeed = ~any(endtf(:) & objtf(:));
        if succeed
            try
                g.moveToPoint([movex;movey;p.zht]);
                curx = movex;
                cury = movey;
            catch moveex
                disp(moveex)
                succeed = false;
            end
        end
    end

end