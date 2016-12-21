function update_alex
[stat,res] = system(sprintf('git -C "%s" pull', mfiledir));
if stat == 0
    disp(res)
else
    warning('code failed to update: %s', res);
end