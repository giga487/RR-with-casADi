
clear
clc

addpath('D:/casadi/');
import casadi.*

parameter = [1.3,1.6;1000,850];

% Degree of interpolating polynomial
d = 3;

% Get collocation points
tau_root = [0 collocation_points(d, 'legendre')];

% Coefficients of the collocation equation
C = zeros(d+1,d+1);

% Coefficients of the continuity equation
D = zeros(d+1, 1);

% Coefficients of the quadrature function
B = zeros(d+1, 1);

% Construct polynomial basis
for j=1:d+1
  % Construct Lagrange polynomials to get the polynomial basis at the collocation point
  coeff = 1;
  for r=1:d+1
    if r ~= j
      coeff = conv(coeff, [1, -tau_root(r)]);
      coeff = coeff / (tau_root(j)-tau_root(r));
    end
  end
  % Evaluate the polynomial at the final time to get the coefficients of the continuity equation
  D(j) = polyval(coeff, 1.0);

  % Evaluate the time derivative of the polynomial at all collocation points to get the coefficients of the continuity equation
  pder = polyder(coeff);
  for r=1:d+1
    C(j,r) = polyval(pder, tau_root(r));
  end

  % Evaluate the integral of the polynomial to get the coefficients of the quadrature function
  pint = polyint(coeff);
  B(j) = polyval(pint, 1.0);
end

% Time horizon
T = 100;

% Declare model variables
q1 = SX.sym('q1');
q2 = SX.sym('q2');
dq1 = SX.sym('dq1');
dq2 = SX.sym('dq2');
dq = [dq1;dq2];
q = [q1; q2];
x = [q;dq];
u1 = SX.sym('u1');
u2 = SX.sym('u2');
u = [u1;u2];
pinvB = pinv(B_f(parameter,q));

% Model equations
ddq = pinvB*(u - G_f(parameter,q) - C_f(parameter,q,dq)*dq);
xdot = [q1;q2;ddq];

L = u1^2 + u2^2;

f = Function('f', {x, u}, {xdot, L});

N = 250; % number of control intervals
h = T/N;

% Start with an empty NLP
w={};
w0 = [];
lbw = [];
ubw = [];
J = 0;
g={};
lbg = [];
ubg = [];

% "Lift" initial conditions
Xk = MX.sym('X0', 2);
w = {w{:}, Xk};
lbw = [lbw; 0; 1];
ubw = [ubw; 0; 1];
w0 = [w0; 0; 1];

for k=0:N-1
    % New NLP variable for the control
    Uk = MX.sym(['U_' num2str(k)]);
    w = {w{:}, Uk};
    lbw = [lbw; -1];
    ubw = [ubw;  1];
    w0 = [w0;  0];

    % State at collocation points
    Xkj = {};
    for j=1:d
        Xkj{j} = MX.sym(['X_' num2str(k) '_' num2str(j)], 2);
        w = {w{:}, Xkj{j}};
        lbw = [lbw; -0.25; -inf];
        ubw = [ubw;  inf;  inf];
        w0 = [w0; 0; 0];
    end

    % Loop over collocation points
    Xk_end = D(1)*Xk;
    for j=1:d
       % Expression for the state derivative at the collocation point
       xp = C(1,j+1)*Xk;
       for r=1:d
           xp = xp + C(r+1,j+1)*Xkj{r};
       end

       % Append collocation equations
       [fj, qj] = f(Xkj{j},Uk);
       g = {g{:}, h*fj - xp};
       lbg = [lbg; 0; 0];
       ubg = [ubg; 0; 0];

       % Add contribution to the end state
       Xk_end = Xk_end + D(j+1)*Xkj{j};

       % Add contribution to quadrature function
       J = J + B(j+1)*qj*h;
    end

    % New NLP variable for state at end of interval
    Xk = MX.sym(['X_' num2str(k+1)], 2);
    w = {w{:}, Xk};
    lbw = [lbw; -0.25; -inf];
    ubw = [ubw;  inf;  inf];
    w0 = [w0; 0; 0];

    % Add equality constraint
    g = {g{:}, Xk_end-Xk};
    lbg = [lbg; 0; 0];
    ubg = [ubg; 0; 0];
end

% Create an NLP solver
prob = struct('f', J, 'x', vertcat(w{:}), 'g', vertcat(g{:}));
solver = nlpsol('solver', 'ipopt', prob);

% Solve the NLP
sol = solver('x0', w0, 'lbx', lbw, 'ubx', ubw,...
            'lbg', lbg, 'ubg', ubg);
w_opt = full(sol.x);

% Plot the solution
x1_opt = w_opt(1:3+2*d:end);
x2_opt = w_opt(2:3+2*d:end);
u_opt = w_opt(3:3+2*d:end);
tgrid = linspace(0, T, N+1);
clf;
hold on
plot(tgrid, x1_opt, '--')
plot(tgrid, x2_opt, '-')
stairs(tgrid, [u_opt; nan], '-.')
xlabel('t')
legend('x1','x2','u')
