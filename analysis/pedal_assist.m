% comment out lines you  do not  need

% this  will cope with  impulses from  pedal assist sensor
% first approach will be to use  first order low pass
% impulses will be transformed into  wave with freq  up  to 20Hz (just my guess value)
% those will be  feed into low pass
% I am interested with  very very low  freq

%  first  let see  continuous  time  low  pass
% f ~ 0.5 Hz
omega  = 2*pi * 0.5;
s = tf(tf( [1 0],[1]));

first_order_fil = omega/(s + omega)

%bode(first_order_fil)


%  assume  typical work cycle, impulses  from  pedal  assist 4Hz

[u,t] = gensig('square',0.25,10,0.01);
plot(t,u)


lsim(first_order_fil,u,t)

% proper  tuning  have to be done on real thing
% only test ride will show if, parameter work out to  provide gentle  but
% responsive  control. Intuitively less responsive  will be  more  gentle
% so there will be  tradeoff

% ok  now  lets  try  do  the  same but in  discrete  time


T = 0.01;
a = exp(-T*omega)
z = tf(tf( [1 0],[1],T));

first_order_fil_dis = (1-a)/(z-a);
bode(first_order_fil, first_order_fil_dis)


lsim(first_order_fil,first_order_fil_dis,u,t)






