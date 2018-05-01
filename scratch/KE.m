load parametres.mat

quiv = 0;
xskp = 10; % one arrow every xskp in x
zskp = 1; % one arrow every zskp in z
qscl = 3; % stretching of arrows
KinField = 0;
PotField = 0;
EnField = 0;
SurfField = 0;

print_o_n = 'n';

ftsize1 = 24;
ftsize2 = 18;

%% Coordinates

x = xc(:,1);
y = yc(1,:);
z = 1:length(zc);
z = zc(1,1,:);

ztop= topo;

[zxp,xzp] = meshgrid(z,x);
[yxp,xyp] = meshgrid(y,x);
[zyp,yzp] = meshgrid(z,y);

%[zp,xp]=meshgrid(z(:),x);

nx = length(x);
ny = length(y);
nz = length(z);

numf=num2str(time,'%010.0f');


T=rdmds(['T.' numf ]); 
Tz(:,:)=T(:,1,:);
Tz(:,nz-30)=5.8;
figure(1)
pcolor(xzp,zxp,Tz), shading flat
caxis( [5.49  5.88])
colorbar
hold off


Txy(:,:)=T(:,:,1);

figure(2)
pcolor(xyp,yxp,Txy), shading flat
colorbar
hold off

W=rdmds(['W.' numf ]); 
U=rdmds(['U.' numf ]); 
V=rdmds(['V.' numf ]); 



KExz(:,:)= sqrt(U(:,1,:).^2+V(:,1,:).^2+W(:,1,:).^2);
figure(3)
pcolor(xzp,zxp,KExz), shading flat
colorbar
hold off



%W=rdmds(['W.' numf ]); 
%Wzy(:,:)=W(10,:,:);
%figure(3)
%pcolor(yzp,zyp,Wzy), shading flat
%colorbar
%hold off


