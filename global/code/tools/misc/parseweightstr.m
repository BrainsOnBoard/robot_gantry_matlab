function wt=parseweightstr(wstr)
wstr = lower(wstr);

if any(strcmp(wstr,{'wta','equal','norm'}))
    wt = wstr;
elseif startswith(wstr,'infomax')
    if length(wstr)==7
        wt = {'infomax',120};
    else
        wt = {'infomax',str2double(wstr(8:end))};
    end
elseif startswith(wstr,'norm')
    wt = { 'norm', str2double(wstr(5:end)) };
elseif wstr(1)=='['
    wt = eval(wstr);
else
    error('invalid weight string')
end