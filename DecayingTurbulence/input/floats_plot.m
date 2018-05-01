clear all
flts=read_flt_traj('float_trajectories',8);

time1= 5*3600/(flts(1).time(1));

%time2= 4024;  %37 *3600/40;

time2= size(flts(1).time,2);

figure(5);
for k=1:1:625;
    
    %plot(flts(k).time,flts(k).z);
    
    plot(flts(k).time(time1:time2)/(3600),flts(k).z(time1:time2));
    hold on;
end;
hold off


%figure(6);
%for k=1:1:900;
%    
%    %plot(flts(k).time,flts(k).z);
%    
%    plot(flts(k).x(time1:time2),flts(k).y(time1:time2));
%    hold on;
%end;
%hold off




light=flts;

for k=1:1:625;
    %light(k).z = exp((flts(k).z)/6.5);
    %meanlight(k) = sum(light(k).z(time1:time2))/(time2-time1);
    
    for tt=time1:1:time2;
        if( flts(k).z(tt) > -100)
            light(k).y(tt) = 1;
        else
            light(k).y(tt) = 0;
        end
    end
    meanlight2(k) = 24*sum(light(k).y(time1:time2))/(time2-time1);
end

%figure(6);
%hist(meanlight,50)
%hold off

figure(7);
hist(meanlight2,50)
hold off
