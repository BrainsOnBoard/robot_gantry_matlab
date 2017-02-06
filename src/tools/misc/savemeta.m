function savemeta(fname,varargin)
d = dbstack;
if numel(d)>=2
    mfn = d(2).file;
else
    mfn = '';
end
metadata = struct('username',username,'hostname',hostname,'datetime',datestr(now), ...
                  'mfilename',mfn,'matlabversion',version);
if isunix
    metadata.sge_queue = getenv('QUEUE');
    metadata.sge_jobid = getenv('JOB_ID');
end
assignin('caller','metadata',metadata);

if numel(varargin)==0
    varstr = '';
else
    varstr = [',''metadata'',''', joinstr(''',''',varargin), ''''];
end

lst = find(fname=='/' | fname=='\',1,'last');
if ~isempty(lst)
    dname = fname(1:lst);
    if ~exist(dname,'dir')
        fprintf('Creating directory %s...\n',dname)
        mkdir(dname)
    end
end

if exist(fname,'file')
    warning('file already exists. overwriting!')
end
fprintf('Saving to %s...\n',fname);
evalin('caller',sprintf('save(''%s''%s);',fname,varstr));