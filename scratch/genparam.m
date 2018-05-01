clear all

%load ../input/initialisation

xc=rdmds('XC');
xg=rdmds('XG');

yc=rdmds('YC');
yg=rdmds('YG');

zc=rdmds('RC');
zf=rdmds('RF');

topo = rdmds('Depth');

[stat,mess] = fileattrib('T.0*');
nfiles = size(mess,2);

nz = length(zc);

nout=100; % intervalle de sortie en iterations
intert=1; % un fichier sur intert est analyse
maxout=(nfiles-2)*nout/2; % iteration de fin du calcul
%nper = maxout/niteper ; %nombre de periodes

iteini =  0;

itefin =  6000000;

dt = 1000;% pas de temps deltaT

grav=9.81;

save('parametres','xg','topo','intert','dt','grav','xc','yg','yc','zc','zf',...
    'maxout','iteini','itefin','nout','nz')
