function fn=matfileaddext(fn)
if length(fn) < 4 || ~strcmpi(fn(end-3:end),'.mat')
    fn = [fn '.mat'];
end