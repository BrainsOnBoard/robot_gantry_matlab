
clear

% arenafn = 'arena1_boxes'; %[];
% whroute = 1;
% whdataset = 2;
%
% whtrial = 1;
% whoffs = 2;

fields = {'curx','cury','curth','goalx','goaly','isbad','head','headnoise','whsn','curz'};
fscale = [true true false true true false false false false false false];

dlist = dir(fullfile(routes_datadir,'route_*'));
for i = 1:length(dlist)
    if dlist(i).isdir
        cdname = dlist(i).name;
        cdatadir = fullfile(routes_datadir,cdname);
        datafn = fullfile(cdatadir,'params.mat');
        % sprintf('route_%s_%03d_trial_%04d_offs_%04d.mat',arenafn,whroute,whtrial,whoffs));
        load(datafn)
        p = pr.routedat_p;
        
        rd = load(fullfile(routes_routedir,cdname(1:end-4)),'clx','cly','rclx','rcly','cli','whclick');
        
        outfn = fullfile(routes_datadir,['comb_' cdname '.mat']);
        if exist(outfn,'file')
            warning('file %s already exists. skipping.',outfn)
            continue
        end
        
        for j = 1:length(fields)
            combd.(fields{j}) = cell(1,length(p.startoffs));
            for k = 1:length(p.startoffs)
                combd.(fields{j}){k} = NaN(pr.maxnsteps(k),pr.ntrialsperroute);
            end
        end
        for j = 1:length(p.startoffs)
            %             [curx{j},cury{j},th{j}] = deal(NaN(pr.maxnsteps(j)+1,pr.ntrialsperroute));
            %             isbad{j} = false(pr.maxnsteps(j)+1,pr.ntrialsperroute);
            for k = 1:pr.ntrialsperroute
                for l = 1:pr.maxnsteps(j)
                    cfn = fullfile(cdatadir,sprintf('trial%04d_offs%04d_step%04d.mat',k,j,l));
                    if ~exist(cfn,'file')
                        break
                    end
                    load(cfn,'d')
                    for m = 1:length(fields)
                        if ~isempty(d.(fields{m}))
                            if fscale(m)
                                combd.(fields{m}){j}(l,k) = d.(fields{m})*p.arenascale/1000;
                            else
                                combd.(fields{m}){j}(l,k) = d.(fields{m});
                            end
                        end
                    end
                    %                     if l==1
                    %                         x{j}(1,k) = d.curx*p.arenascale/1000;
                    %                         y{j}(1,k) = d.cury*p.arenascale/1000;
                    %                     end
                    %                     curx{j}(l,k) = d.curx*p.arenascale/1000;
                    %                     cury{j}(l,k) = d.cury*p.arenascale/1000;
                    %                     th{j}(l,k) = d.curth;
                    %                     isbad{j}(l,k) = d.isbad;
                end
                %                 if l==pr.maxnsteps(j)
                %                     curx{j}(end,k) = d.goalx*p.arenascale/1000;
                %                     cury{j}(end,k) = d.goaly*p.arenascale/1000;
                %                 end
            end
        end
        
        fprintf('writing to %s...\n',outfn)
        save(outfn,'combd','pr','rd');
    end
end