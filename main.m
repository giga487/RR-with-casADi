
clear
clc

addpath('utils')
addpath('Dinamica')
addpath('D:\casadi')
import casadi.*

%% 
a = sym('a', [2 1],'real');
m = sym('m', [2 1],'real');
l = sym('l', [2 1],'real');
q = sym('q', [2 1],'real');
dq = sym('dq', [2 1],'real');
I = sym('I', [2,1],'real');

parameter = [a,m];

g0 = 9.81;
h = 0;

I(1) = 1/3*m(1)*l(1)^2;
I(2) = 1/3*m(2)*l(2)^2;

I1 =  [I(1),0,0;
         0,I(1),0;
         0,0,I(1);];
     
I2 = [I(2),0,0;
       0,I(2),0;
       0,0,I(2);];
   
dinamica_function;

%% OPTIMIZER
N = 100; % number of control intervals

opti = casadi.Opti(); % Optimization problem

%% 


q = opti.variable(2, N+1);
dq = opti.variable(2, N+1);
ddq = opti.variable(2, N+1);
tau = opti.variable(2,N+1);   % control trajectory (throttle)

q0 = [0, 0];
qend = [pi/4, -pi/3];
%% DINAMICA OK
Kt = 1;
KT = 0.01;

T = opti.variable();
J = Kt*(tau(1)^2+tau(2)^2)+KT*T;
opti.minimize(J); % race in minimal time

dt = T/N; % length of a control interval
parameter = [1.3,1.6;1000,850];
Max_torque = 40000;

for k = 1:N % loop over control intervals
       ddq(:,k) = B_f(parameter,q(:,k))\(tau(:,k) - G_f(parameter,q(:,k)) - C_f(parameter,q(:,k),dq(:,k))*dq(:,k));
       dq_next = dq(:,k) + dt*ddq(:,k);
       opti.subject_to( dq(:,k+1) == dq_next); % close the gaps
       q_next = q(:,k) + dt*dq(:,k);
       opti.subject_to( q(:,k+1) == q_next); % close the gaps
end


%% BOUNDARIES
opti.subject_to(T>=0); % Time must be positive
opti.subject_to(q(1,N+1) == qend(1));   
opti.subject_to(q(2,N+1) == qend(2)); 
opti.subject_to(-Max_torque < tau(1) < Max_torque);   
opti.subject_to(-Max_torque < tau(2) < Max_torque); 

%% INIT COND
opti.set_initial(T, 1);
opti.subject_to(q(1,1) == q0(1));   % start at position 0 ...
opti.subject_to(q(2,1) == q0(2));   % start at position 0 ...
% opti.subject_to(tau(1) == 0);   % start at position 0 ...
% opti.subject_to(tau(2) == 0);  % ... from stand-still 

%% 
% ---- solve NLP              ------
opti.solver('ipopt'); % set numerical backend
sol = opti.solve();   % actual solve

%%
t = linspace(0,sol.value(T),N+1);

q1_sol = sol.value(q(1,:))*180/pi;
q2_sol = sol.value(q(2,:))*180/pi;

figure
hold on
plot(t,sol.value(q)*180/pi);
legend("q1","q2");
title("angular position");
grid on;
hold off

figure
hold on
plot(t,sol.value(tau));
legend("tau1","tau2");
title("tau")
grid on;
hold off

q_plot_end = sol.value(q(:,end));
q_plot_begin = sol.value(q(:,1));
plot_joint(parameter,q_plot_end)
plot_joint(parameter,q_plot_begin)





