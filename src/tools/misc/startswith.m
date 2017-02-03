function tf = startswith(str,sw)
tf = length(str)>=length(sw) && strcmp(str(1:length(sw)),sw);