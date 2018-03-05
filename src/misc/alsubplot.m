function alsubplot(a,b,row,col)
persistent spsz

if nargin==3
    col = 1;
end

if nargin>2
    spsz = [a b];
elseif isempty(spsz)
    error('subplot size must be specified');
else
    row = a;
    if nargin==1
        col = 1;
    else
        col = b;
    end
    a = spsz(1);
    b = spsz(2);
end

if numel(row)==1 && numel(col)>1
    row = row*ones(size(col));
elseif numel(col)==1 && numel(row)>1
    col = col*ones(size(row));
end

if any(col < 1) || any(col > b) || any(row < 1) || any(row > a)
    error('invalid row or col')
end
subplot(a,b,sub2ind([b a],col,row));
