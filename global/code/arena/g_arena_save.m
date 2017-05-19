function objverts=g_arena_save(arenafn,coords,objhts)

fn = fullfile(g_dir_arenas,matfileaddext(arenafn)); % out file
if exist(fn,'file')
    error('file already exists')
end

% x and y offsets, from edge of arena to masking tape crosses
offs = [570 490];

% load arena limits
load('arenadim','lim')

objverts = cell(size(coords));
for i = 1:length(coords)
    c = coords{i};
    c = c*10; % convert to mm
    c2 = bsxfun(@minus, c, offs); % subtract offsets
    
    % check for out of range values
    lows = c2 < 0;
    highs = bsxfun(@gt, c2, lim(1:2)');
    nbads = sum(lows(:) | highs(:));
    if nbads > 0
        warning('%d values out of range for object %d', nbads, i);
    end
    
    % cap out of range values
    c2(lows) = 0;
    c2(highs(:,1),1) = lim(1);
    c2(highs(:,2),2) = lim(2);
    c2 = c2';
    
    % convert to row vectors
    objverts{i} = c2(:)';
end

% convert objhts to mm
objhts = objhts*10;

% save object vertices and heights to file
savemeta(fn,'objverts','objhts');

% figure(1);clf
% g_fig_drawobjverts(objverts);