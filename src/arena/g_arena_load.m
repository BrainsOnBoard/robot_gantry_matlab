function [objverts,objhts]=g_arena_load(arenafn)
arenafn = matfileremext(arenafn);

[coords,objhts,isoffset] = eval(arenafn);

% x and y offsets, from edge of arena to masking tape crosses
offs = [570 490];

% load arena limits
load('arenadim','lim')

objverts = cell(size(coords));
for i = 1:length(coords)
    c = coords{i};
    if ~isoffset
        c = bsxfun(@minus, c, offs); % subtract offsets
    end
    
    % check for out of range values
    lows = c < 0;
    highs = bsxfun(@gt, c, lim(1:2)');
    nbads = sum(lows(:) | highs(:));
    if nbads > 0
        warning('%d values out of range for object %d in %s', nbads, i, arenafn);
    end
    
    % cap out of range values
    c(lows) = 0;
    c(highs(:,1),1) = lim(1);
    c(highs(:,2),2) = lim(2);
    c = c';
    
    % convert to row vectors
    objverts{i} = c(:)';
end