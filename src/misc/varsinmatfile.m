function tf=varsinmatfile(fn,varargin)
    fn = matfileaddext(fn);

    tf = false(numel(varargin),1);
    
    if ~exist(fn,'file')
        return;
    end
    
    vars = who('-file',fn);
    for i = 1:numel(varargin)
        tf(i) = any(strcmp(vars,varargin{i}));
    end
end