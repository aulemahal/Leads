% This is a matlab script that generates the input data

% $Header: /u/gcmpack/MITgcm/verification/tutorial_deep_convection/input/gendata.m,v 1.3 2008/04/24 01:48:52 jmc Exp $
% $Name:  $

clear all

% Dimensions of grid
nx=600;
ny=30;
nz=500;
% Nominal depth of model (meters)
H=300;
% Size of domain
Lx=600;
% Radius of cooling disk (m)
Rc=6000.;
% Horizontal resolution (m)
dx=Lx/nx;
% Rotation
f=1.e-4;
% Stratification
N=9.5E-3;
% surface temperature
Ts=20.;
% Flux : Cooling disk & noise added to cooling
Qval=200; Q1=.0001;
%Qval=200; Q1=0.;

% Gravity
g=10.;
% E.O.S.
alpha=2.e-4;

Tz=N^2/(g*alpha);

dz=H/nz;
%sprintf('delZ = %d * %7.6g,',nz,dz)

x=(1:nx)*dx;x=x-mean(x);
y=(1:ny)*dx;y=y-mean(y);
z=-dz/2:-dz:-H;


%====================================================
% Temperature profile

%--> start from idealised

Tref=Ts+Tz*z-mean(Tz*z);
for i=1:nz/2
    Tref(i)=20;
end
%plot(Tref)
Txyz=ones(nx,ny,nz);
for i=1:nz
   Txyz(:,:,i) = Tref(i)*Txyz(:,:,i);
end
%Tyz(:,:)=zeros(ny,nz);
%Tyz(:,:)=Txyz(10,:,:);
%pcolor(Tyz);
%fid=fopen('Tini','w','b'); fwrite(fid,Txyz,'real*8'); fclose(fid);


%--> start from data

profile = load('OnsetwithDaylength');

Z1=profile(:,1);
Z1=-Z1;
Tprofile = profile(:,2) ;


dz3=H/300;
z3=-dz3/2:-dz3:-H;

AA = interp1(Z1,Tprofile,z3,'spline');

%plot(AA)

Txyz=ones(nx,ny,nz);
for i=1:200
   Txyz(:,:,i) = AA(1)*Txyz(:,:,i);
end
for i=201:nz
   Txyz(:,:,i) = AA(i-200)*Txyz(:,:,i);
end
%Tyz(:,:)=zeros(nx,nz);
%Tyz(:,:)=Txyz(:,1,:);
%5pcolor(Tyz);

fid=fopen('Tini','w','b'); fwrite(fid,Txyz,'real*8'); fclose(fid);



%==========================================================================
% Surface heat flux : refine the grid (by 3 x 3) to assign mean heat flux

Qc=zeros(nx,ny);
Qc(:,:)=Qval+Q1*(0.5+rand([nx,ny]));
fid=fopen('Qo','w','b'); fwrite(fid,Qc,'real*8'); fclose(fid);

%==========================================================================
% ---- Floats initial ----

%fid=fopen('flt_ini_pos.bin','r','b');
%FLTini = fread(fid,'real*8');

Nfloats = 500;

FLTini = zeros( 9, Nfloats+1 );

%FLTini(1) = Nfloats ;
%- fill-up 1rst reccord
FLTini(1,1) = Nfloats;
FLTini(6,1) = Nfloats;

for i=2:Nfloats+1
   n = i-1;
   
%c     - npart   A unique float identifier (1,2,3,...)

   FLTini(1,i)=n ;

%c     - tstart  start date of integration of float (in s)
%c               Note: If tstart=-1 floats are integrated right from the 
%c               beginning

   FLTini(2,i)= -1 ;

%c     - xpart   x position of float (in units of XC)
   
   FLTini(3,i)=(Nfloats-n+0.5)*Lx/Nfloats ;

%c     - ypart   y position of float (in units of YC)
   
   FLTini(4,i)=  1. ;

%c     - kpart   actual vertical level of float
   
   FLTini(5,i)= -1.;

%c     - kfloat  target level of float (should be the same as kpart at
%c               the beginning)
   
   FLTini(6,i)=0. ;

%c     - iup     flag if the float 
%c               - should profile   ( >  0 = return cycle (in s) to surface) 
%c               - remain at depth  ( =  0 )
%c               - is a 3D float    ( = -1 ).
%c               - should be advected WITHOUT additional noise ( = -2 ). 
%c                 (This implies that the float is non-profiling)
%c               - is a mooring     ( = -3 ), i.e. the float is not advected
   
   FLTini(7,i)=-1 ;

%c     - itop    time of float the surface (in s)
   
   FLTini(8,i)=0 ;

%c     - tend    end  date of integration of float (in s)
%c               Note: If tend=-1 floats are integrated till the end of
%c               the integration   

   FLTini(9,i)=-1 ;
   

end


fid=fopen('flt_ini_pos.bin','w','b'); fwrite(fid,FLTini,'real*8'); fclose(fid);

%==========================================================================
% ---- RBCS restoring boundary condition ----


Mask = Txyz;
relaxT = Txyz;

Mask(:,:,:)=0;

for i=nz-30:nz
    Mask(:,:,i)=1; 
end

% Maskz=zeros(nx,nz);
% relaxTz=zeros(nx,nz);
% Maskz(:,:) = Mask(:,1,:) ;
% relaxTz(:,:) = relaxT(:,1,:);
% figure (3);pcolor(relaxTz)

fid=fopen('rbcs_mask.bin','w','b'); fwrite(fid,Mask,'real*8'); fclose(fid);
fid=fopen('relaxT.bin','w','b'); fwrite(fid,relaxT,'real*8'); fclose(fid);




 Uz=rdmds(['U.0000014000']);
 fid=fopen('U.init','w','b'); fwrite(fid,Uz,'real*8'); fclose(fid);
 Vz=rdmds(['V.0000014000']);
 fid=fopen('V.init','w','b'); fwrite(fid,Vz,'real*8'); fclose(fid);
 Wz=rdmds(['W.0000014000']);
 fid=fopen('W.init','w','b'); fwrite(fid,Wz,'real*8'); fclose(fid);
 Tz=rdmds(['T.0000014000']);
 fid=fopen('T.init','w','b'); fwrite(fid,Tz,'real*8'); fclose(fid);
 Sz=rdmds(['S.0000014000']);
 fid=fopen('S.init','w','b'); fwrite(fid,Sz,'real*8'); fclose(fid);
 
 

