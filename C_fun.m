function C = C_fun(a1,dq1,dq2,l2,m2,q2)
%C_FUN
%    C = C_FUN(A1,DQ1,DQ2,L2,M2,Q2)

%    This function was generated by the Symbolic Math Toolbox version 8.4.
%    13-May-2020 11:44:24

C = reshape([-a1.*dq2.*l2.*m2.*sin(q2),a1.*dq1.*l2.*m2.*sin(q2),-a1.*dq1.*l2.*m2.*sin(q2)-a1.*dq2.*l2.*m2.*sin(q2),0.0],[2,2]);
