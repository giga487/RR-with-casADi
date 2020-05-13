%Calcolo dinamica
%% Cinematica

KDir = simplify(matrixDH(a(1),0,0,q(1))*matrixDH(a(2),0,0,q(2)));

%% Calcolo Dinamica
syms g0 real;

h = 0;
I(1) = 1/3*m(1)*l(1)^2;
I(2) = 1/3*m(2)*l(2)^2;

I1 =  [I(1),0,0;
         0,I(1),0;
         0,0,I(1);];
     
I2 = [I(2),0,0;
       0,I(2),0;
       0,0,I(2);];

TG1 = matrixDH(l(1),0,0,q(1));
pG1 = TG1(1:3,4);
rG1 = TG1(1:3,1:3);

p = pG1;
r = rG1;

JpG1 = [jacobian(p(1),[q(1),q(2)]);
        jacobian(p(2),[q(1),q(2)]);
        jacobian(p(3),[q(1),q(2)]);];
    
%JoG1    
dR_x1 = diff(r,q(1));
dR_x2 = diff(r,q(2));

TOR1vee = simplify(r'*dR_x1);
TOR2vee = simplify(r'*dR_x2);

TOR1 = [TOR1vee(3,2);TOR1vee(1,3);TOR1vee(2,1)];
TOR2 = [TOR2vee(3,2);TOR2vee(1,3);TOR2vee(2,1)];

JoG1 =  simplify([TOR1,TOR2]);    

%%

TG2 = simplify(matrixDH(a(1),0,0,q(1))*matrixDH(l(2),0,0,q(2)));
pG2 = TG2(1:3,4);
rG2 = TG2(1:3,1:3);

p = pG2;
r = rG2;

JpG2 = simplify([jacobian(p(1),[q(1),q(2)]);
        jacobian(p(2),[q(1),q(2)]);
        jacobian(p(3),[q(1),q(2)]);]);
%JoG2    
dR_x1 = diff(r,q(1));
dR_x2 = diff(r,q(2));

TOR1vee = simplify(r'*dR_x1);
TOR2vee = simplify(r'*dR_x2);

TOR1 = [TOR1vee(3,2);TOR1vee(1,3);TOR1vee(2,1)];
TOR2 = [TOR2vee(3,2);TOR2vee(1,3);TOR2vee(2,1)];

JoG2 =  simplify([TOR1,TOR2]);     

JG2 = JpG2(1:2,1:2); %%sarebbe così, ma tanto è inutile.
    
%% B

Bp1 = simplify(m(1)*(JpG1')*JpG1);
Bo1 = simplify((JoG1')*I1*(JoG1));
Bp2 = simplify(m(2)*(JpG2')*JpG2);
Bo2 = simplify((JoG2')*I2*(JoG2));

B = Bp1 + Bo1 + Bp2 + Bo2;
C = CoriolisMatrix(B,q,dq);
% 
g = [0,-g0,0]';
% 
GJoint = -(m(1)*(JpG1')*g+m(2)*(JpG2')*g);
%
G = simplify(GJoint);

%%

B_f1 = matlabFunction(B,'File','B_fun','Optimize',false);%%
C_f1 = matlabFunction(C,'File','C_fun','Optimize',false);
G_f1 = matlabFunction(G,'File','G_fun','Optimize',false);







