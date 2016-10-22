function d=sumabsdiff(x,y)
d = sum(sum(abs(bsxfun(@minus,x,y)),1),2);