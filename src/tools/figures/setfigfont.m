function setfigfont(fontname,fontsize)
set(gca,'FontName',fontname,'FontSize',fontsize);
set(findall(gcf,'type','text'),'FontName',fontname,'FontSize',fontsize);