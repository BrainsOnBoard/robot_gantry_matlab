function str=numjoin(nums,delim)
if nargin < 2
    delim = ',';
end
str = strjoin(mat2strcell(nums),delim);
