function str=mat2strcell(x)
str = cellfun(@num2str,num2cell(x),'UniformOutput',false);
