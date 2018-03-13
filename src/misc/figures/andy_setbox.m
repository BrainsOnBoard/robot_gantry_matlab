function andy_setbox(Hdl)

if(nargin==0) 
    set(gca,'Box','off','TickDir','out','Units','normalized')
else
    set(Hdl,'Box','off','TickDir','out','Units','normalized')
end