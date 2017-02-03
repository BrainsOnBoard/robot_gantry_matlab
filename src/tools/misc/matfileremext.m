function fn=matfileremext(fn)
if length(fn) >= 4 && strcmpi(fn(end-3:end),'.mat')
    fn = fn(1:end-4);
end