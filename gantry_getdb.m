function gantry_getdb

p.imsep = 100; % mm
p.xs = 0:p.imsep:2000;
p.ys = 0:p.imsep:1000;
p.startoffs = 100;
p.zht = 300;
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
fprintf('getting image database\n%dx%d (=%d) ims\n',length(p.ys),length(p.xs),nim)

p.maxV = [151;151;151];
p.maxA = [20;20;20];
acuity = 1;

save(fullfile(p.imdir,'im_params.mat'),'p')


% Gantry(debug, homeGantry, disableZ, acuity, maxV, maxA)
g = alexGantry(false,true,false,acuity,p.maxV,p.maxA);
try 
    cim = 1;
    tic
    for xi = 1:length(p.xs)
        if mod(xi,2)
            cys = 1:length(p.ys);
        else
            cys = length(p.ys):-1:1;
        end
        for yi = cys
            fprintf('image %d/%d\n',cim,nim)
            g.moveToPoint([p.startoffs+p.xs(xi);p.startoffs+p.ys(yi);p.zht]);
            fr = g.getRawFrame;
            save(fullfile(p.imdir,sprintf('im_%03d_%03d.mat',yi,xi)),'fr')
            cim = cim+1;
        end
    end
    ttot = toc;
    fprintf('Time: %gs (%gs per image)\n',ttot,ttot/nim)
    
    g.homeGantry(false);
    
    delete(g)
catch ex
    delete(g)
    rethrow(ex)
end
