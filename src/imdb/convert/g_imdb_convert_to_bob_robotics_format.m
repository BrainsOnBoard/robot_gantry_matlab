function g_imdb_convert_to_bob_robotics_format

olddir = pwd;

cd(g_dir_imdb_raw);
d = dir;

for i = 1:length(d)
    if ~d(i).isdir
        continue
    end
    
    dname = d(i).name;
    if dname(1) == '.'
        continue
    end
    fprintf('Processing %s...\n', dname)
    
    cd(dname)
    load('im_params.mat','p');
    
    % if it's a 2d database
    is2d = ~isfield(p,'zs');
    if is2d
        p.zs = p.zht;
    end
    
    % get date from path
    data.metadata.time = dname(1:10);
    assert(~varsinmatfile('im_params.mat','metadata'));
    
    % grid parameters
    data.metadata.type = 'grid';
    data.metadata.grid.beginAtMM = [p.xs(1) p.ys(1) p.zs(1)];
    data.metadata.grid.separationMM = p.imsep * ones(1,3);
    if is2d
        p.imsep(3) = 0;
    end
    data.metadata.grid.size = [length(p.xs) length(p.ys) length(p.zs)];
    
    % camera properties
    data.metadata.camera.name = 'gantry';
    data.metadata.camera.resolution = p.imsz([2 1]);
    data.metadata.camera.isPanoramic = 1;
    
    % gantry-specific properties
    if isfield(p,'lim')
        data.metadata.gantry.innerLimits = p.lim(:)';
    end
    data.metadata.gantry.offset = p.offset(:)';
    if isfield(p,'zclear')
        data.metadata.gantry.zClearance = p.zclear;
    end
    if isfield(p,'zoffs')
        data.metadata.gantry.baseHeight = p.zoffs;
    end
    if isfield(p,'objgridac')
        data.metadata.gantry.objectGridSpacing = p.objgridac;
    end
    if isfield(p,'headclear')
        data.metadata.gantry.headClearance = p.headclear;
    end
    if isfield(p,'arenafn')
        data.metadata.gantry.arenaName = char(p.arenafn);
    else
        data.metadata.gantry.arenaName = '';
    end
    if isfield(p,'maxA')
        data.metadata.gantry.maximumAcceleration = p.maxA(:)';
    end
    if isfield(p,'maxV')
        data.metadata.gantry.maximumVelocity = p.maxV(:)';
    end
    
    % other properties
    data.metadata.needsUnwrapping = 1;
    data.metadata.isGreyscale = double(p.imsz(3) > 1);
    
    % write metadata file
    YAML.write('database_metadata.yaml',data);
    clear data
    
    % write entries file
    fid = fopen('database_entries.csv','w');
    fprintf(fid,'X [mm], Y [mm], Z [mm], Heading [degrees], Filename, Grid X, Grid Y, Grid Z\n');
    for zi = 1:length(p.zs)
        for yi = 1:length(p.ys)
            for xi = 1:length(p.xs)
                fname = sprintf('im_%03d_%03d_%03d.png',xi,yi,zi);
                if exist(fname,'file')
                    fprintf(fid, '%d, %d, %d, 0, %s, %d, %d, %d\n', p.xs(xi), p.ys(yi), p.zs(zi), fname, xi-1, yi-1, zi-1);
                end
            end
        end
    end
    fclose(fid);
    
    cd ..
end

cd(olddir);
