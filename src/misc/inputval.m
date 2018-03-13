function val=inputval(txt,default)
% get user input, with default value specified

% ugly hack to convert to string
strdef = strtrim(evalc('disp(default)'));

% get input
val = input(sprintf('%s [%s]: ',txt,strdef));
if isempty(val)
    val = default;
end
