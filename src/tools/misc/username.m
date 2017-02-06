function un=username
if isunix
    [exitcode,un] = system('whoami');
    if exitcode==0
        un = strtrim(un);
    else
        un = getenv('USER');
    end
else
    un = getenv('USERNAME');
end