
clear all 
genparam     
x = xc(:,1); 
y = yc(1,:);  
z = 1:length(zc);
z=-z;
T=rdmds(['T.0000018000']);
hslice = surf(linspace(0,600,300),linspace(0,600,300), zeros(300));
rotate(hslice,[-1,0,0],-1) 
xd = get(hslice,'XData');
yd = get(hslice,'YData');
zd = get(hslice,'ZData');
h = slice(x,y,z,T,xd,yd,zd);
set(h,'FaceColor','interp','EdgeColor','none','DiffuseStrength',.8)
hold on
hx = slice(x,y,z,T,2,[],[]);
set(hx,'FaceColor','interp','EdgeColor','none')
hy = slice(x,y,z,T,[],2,[]);
set(hy,'FaceColor','interp','EdgeColor','none')
hz = slice(x,y,z,T,[],[],-1);
set(hz,'FaceColor','interp','EdgeColor','none')
daspect([1,1,1])
axis tight
box on
%view(-38.5,16)
camzoom(1.1)
camproj perspective
caxis([5.83,5.87])

%plot3(flts(k).x(t1:t2),flts(k).y(t1:t2),flts(k).z(t1:t2),'LineWidth',2)


hold off
