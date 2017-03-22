clear

% p.arenafn = [];

snapweighting = {'infomax120'}; %,'wta'}; %,'norm5','[1,0.75,0.25]'};
snapweightinglabel = {'wta'}; %,'winner-take-all'}; %,'normalised (n=5)','fixed (n=3)'};
fov = 360; % 90:90:
figsz = [20 10];
dosave = true;
dosuptit = false;

nth = 360;
% zht = 200;
fignrow = 2;

[imdir,imdirshort,imlabel] = imdb_choosedb3d;
load(fullfile(imdir,'im_params.mat'));

whroute = input('Enter which route num: ');

% zi = find(p.zs==zht);

for i = 1:length(whroute)
    load(fullfile(mfiledir,'routedat',sprintf('route_%s_%03d.mat',matfileremext(p.arenafn),whroute(i))),'ptr')
    for j = 1:length(snapweighting)
        for k = 1:length(fov)
            fignum = sub2ind([length(fov),length(snapweighting),length(whroute)],k,j,i);
            figure(1)
            clf
            for zi = 1:length(p.zs)
                [heads,minval,whsn,rd] = g_live_compareimdb_getdata(p.arenafn,whroute(i),imdirshort,zi,snapweighting{j},nth,fov(k));
                [oxs,oys] = ndgrid(p.xs*rd.p.arenascale/1000,p.ys*rd.p.arenascale/1000);
                
                subplot(fignrow,ceil(length(p.zs)/fignrow),zi);
                g_fig_drawobjverts(p.arenafn,rd.p.arenascale,'g')
                hold on
                anglequiver(oxs,oys,heads);
                plot(rd.clx,rd.cly,'r+')
                t=title(sprintf('z = %g m',(50+p.zs(zi))*rd.p.arenascale/1000));
                if ptr.zht==p.zs(zi)
                    set(t,'Color','r')
                end
                
                [fcol,frow] = ind2sub([3,2],zi);
                if fcol==1
                    ylabel('y (m)')
                else
                    set(gca,'YTick',[])
                end
                if frow~=2
                    set(gca,'XTick',[])
                end
                if zi==5
                    xlabel('x (m)')
                end
            end
            if dosuptit
                suptitle(sprintf('arena: %s - route: %d - fov: %ddeg - weight: %s',imlabel,whroute(i),fov(k),snapweightinglabel{j}))
            end
            if dosave
                [fcnt,fnames{fignum}] = savefig(sprintf('fig%03d_%s_r%03d_fov%03d_wt_%s.pdf',fignum,imdirshort,whroute(i),fov(k),snapweighting{j}),figsz);
            end
        end
        
    end
end

if dosave
    rstr = sprintf('%d_',whroute);
    combinepdfs(fnames,fullfile(mfiledir,'figures',sprintf('%04d_%s_r%s%s.pdf',fcnt,mfilename,rstr,imdirshort)));
end