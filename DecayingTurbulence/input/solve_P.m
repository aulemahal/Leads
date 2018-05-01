
%clear all
%flts=read_flt_traj('float_trajectories',8);
load('Light70N_0E_0301-08.txt','r');
I0(:,1)=Light70N_0E_0301_08(:,4);

dt = flts(1).time(1);
time1= 5  *3600/dt;
time2= size(flts(1).time,2);
Nfloats = size(flts,2);

count=0;
for t=time1+1:time2
if (flts(1).time(t) ==  flts(1).time(t-1))	
  count=count+1;
end
end

Ttot = time2-time1-count;

tsec=zeros(Nfloats,Ttot);
Zt=zeros(Nfloats,Ttot);
tt=1;
for t=time1:time2
if (flts(1).time(t) ~=  flts(1).time(t-1))
  for k=1:Nfloats
	  tsec(k,tt) = flts(k).time(t)-flts(k).time(time1);
	  Zt(k,tt) = flts(k).z(t);
  end
  tt=tt+1;
end
end

P=zeros(Nfloats,Ttot);

mu0=1/(3600*24);
kd= 0.0384+(0.0138*0.02) ;
m=0.0748/(3600*24);
alpha=0.0538/(3600*24); 
mu_max=0.536/(3600*24); 


%for ii=1:1:3
	  ii=2;


%m=   0.0748/(3600*24);              %0.01*(5*(ii-1))/(3600*24)

m=   0.052/(3600*24);

%0.01*(5*(ii-1))

%k=1;

for k=1:1:Nfloats;    
    
% ----------- 1st method ----------- 
    
%    P(k,1) = 0.1;
%    P(k,2) = 0.1;
%    P(k,3) = 0.1;
%    mu = mu0*exp(kd*(flts(k).z(time1)));
%    CC1 = ( mu - m )*P(k,1);
%    CC2 = ( mu - m )*P(k,2);
%    for t=3:1:Ttot-1
%        mu = mu0*exp(kd*(flts(k).z(t+time1)));
%        CC3 = ( mu - m )*P(k,t);
%        P(k,t+1) = P(k,t) + (dt/12)*(23*CC3-16*CC2+5*CC1);
%        CC2=CC3;
%        CC1=CC2;
%    end       

% ----------- 2nd method -----------        

    P(k,1) = 0.1;
    P(k,2) = 0.1;
    P(k,3) = 0.1;
    I = I0(time1)*exp(kd*(flts(k).z(time1)));
%    I = I0(time1)*exp(kd*Zt(k,time1));
    mu = (alpha*I)*mu_max / sqrt(mu_max^2 + (alpha*I)^2);
    CC1 = ( mu - m )*P(k,1);
    CC2 = ( mu - m )*P(k,2);
    for t=3:1:Ttot-1
        I = I0(t+time1)*exp(kd*(flts(k).z(t+time1)));
%        I = I0(t+time1)*exp(kd*Zt(k,time1));
        mu = (alpha*I)*mu_max / sqrt(mu_max^2 + (alpha*I)^2);
        CC3 = ( mu - m )*P(k,t);
        P(k,t+1) = P(k,t) + (dt/12)*(23*CC3-16*CC2+5*CC1);
        CC2=CC3;
        CC1=CC2;
    end       

end

figure(1);
for k=1:2:Nfloats
    plot(flts(1).time(1:Ttot)/3600/24,P(k,1:Ttot))
    hold on
end
for t=1:Ttot
	meanP(t)=mean(P(:,t));
end
plot(flts(1).time(1:Ttot)/3600/24,meanP(1:Ttot),'LineWidth',4,'Color','red')
   %axis([0 flts(1).time(Ttot) 0.06 0.14])
hold off 



% ----------- Analytic -----------        

Tday=60*24;
z=200;

H=1:1:z;
Hzt = zeros(z,Tday);

figure(2)
plot(H)
hold on

for t=1:Tday
  x = alpha*I0(t);
  AA = log(x + sqrt( mu_max^2 + x^2 ));
  BB = log(x*exp(-kd*H) + sqrt( mu_max^2 + (x*exp(-kd*H)).^2 ));
  Hz = mu_max/(kd*m) * (AA-BB);
  Hzt(:,t)=Hz(:);
end

meanHz = zeros(z);
for k=1:z
	meanHz(k)=mean(Hzt(k,:));
end
plot(meanHz)

hold off
