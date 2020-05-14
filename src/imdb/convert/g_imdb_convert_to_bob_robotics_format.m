function g_imdb_convert_to_bob_robotics_format

olddir = pwd;

cd(g_dir_imdb);
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
    params = load('im_params.mat');
    
    % if it's a 2d database
    is2d = ~isfield(params.p,'zs');
    if is2d
        params.p.zs = params.p.zht;
    end
    
    % get date from path
    data.metadata.time = dname(end-13:end-4); % this will only be the date
    datetime(data.metadata.time); % check it's actually a valid date
    assert(~varsinmatfile('im_params.mat','metadata'));
    
    % plain text description of database
    if isfield(params,'label')
        data.metadata.description = params.label;
    end
    
    % grid parameters
    data.metadata.type = 'grid';
    data.metadata.grid.beginAtMM = [params.p.xs(1) params.p.ys(1) params.p.zs(1)];
    data.metadata.grid.separationMM = params.p.imsep * ones(1,3);
    if is2d
        params.p.imsep(3) = 0;
    end
    data.metadata.grid.size = [length(params.p.xs) length(params.p.ys) length(params.p.zs)];
    
    % gantry-specific properties
    if isfield(params.p,'lim')
        data.metadata.gantry.innerLimits = params.p.lim(:)';
    end
    data.metadata.gantry.offset = params.p.offset(:)';
    if isfield(params.p,'zclear')
        data.metadata.gantry.zClearance = params.p.zclear;
    end
    if isfield(params.p,'zclearht')
        data.metadata.gantry.zClearance = params.p.zclearht;
    end
    if isfield(params.p,'zoffs')
        data.metadata.gantry.baseHeight = params.p.zoffs;
    end
    if isfield(params.p,'objgridac')
        data.metadata.gantry.objectGridSpacing = params.p.objgridac;
    end
    if isfield(params.p,'headclear')
        data.metadata.gantry.headClearance = params.p.headclear;
    end
    if isfield(params.p,'arenafn')
        data.metadata.gantry.arenaName = char(matfileremext(params.p.arenafn));
    else
        data.metadata.gantry.arenaName = '';
    end
    if isfield(params.p,'maxA')
        data.metadata.gantry.maximumAcceleration = params.p.maxA(:)';
    end
    if isfield(params.p,'maxV')
        data.metadata.gantry.maximumVelocity = params.p.maxV(:)';
    end
    
    % other properties
    data.metadata.needsUnwrapping = 0;
    data.metadata.isGreyscale = double(size(params.p.imsz==2 || params.p.imsz(3)==1);
    
    % write entries file
    fid = fopen('database_entries.csv','w');
    fprintf(fid,'X [mm], Y [mm], Z [mm], Heading [degrees], Filename, Grid X, Grid Y, Grid Z\n');
    imsz = [];
    for zi = 1:length(params.p.zs)
        for yi = 1:length(params.p.ys)
            for xi = 1:length(params.p.xs)
                fname = sprintf('im_%03d_%03d_%03d.png',xi,yi,zi);
                if exist(fname,'file')
                    fprintf(fid, '%d, %d, %d, 0, %s, %d, %d, %d\n', params.p.xs(xi), params.p.ys(yi), params.p.zs(zi), fname, xi-1, yi-1, zi-1);
                    if isempty(imsz)
                        % read size from image, as p.imsz appears to be
                        % unreliable
                        imsz = size(imread(fname));
                        imsz = imsz([2 1]);
                    end
                end
            end
        end
    end
    fclose(fid);
    
    % camera properties
    data.metadata.camera.name = 'gantry';
    data.metadata.camera.resolution = imsz;
    data.metadata.camera.isPanoramic = 1;
    
    % write metadata file
    YAML.write('database_metadata.yaml',data);
    clear data
    
    cd ..
end

cd(olddir);
