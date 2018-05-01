%clear all
%flts=read_flt_traj('float_trajectories',8);

time1= 5*3600/(flts(1).time(1));

time2= size(flts(1).time,2);

figure(5);
for k=1:1:625;
    
    %plot(flts(k).time,flts(k).z);
    
    plot(flts(k).time(time1:time2)/(3600),flts(k).z(time1:time2));
    hold on;
end;
hold off
count=1

hours=[60:300:time2-time1]*60/3600

for ttt=time1+100:300:time2

%ttt=time1+100;

for k=1:1:625;
    for tt=time1:1:ttt;
        if( flts(k).z(tt) > -100)
            light(k).y(tt) = 60;
        else
            light(k).y(tt) =  0;
        end
    end
	meanlight2(k) = (24/60)*sum(light(k).y(time1:ttt))/(ttt-time1);
end
figure(7);
hist(meanlight2,50)

y(count) = std(meanlight2(:)) 
  count=count+1;
hold on
end

%curve = fit( hours', y', 'exp2');
%plot(curve);hold on 
%plot(hours,y)
