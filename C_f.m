function C = C_f(parameter,q,dq)

    a1 = parameter(1,1);
    a2 = parameter(2,1);
    m1 = parameter(1,2);
    m2 = parameter(2,2);
    q1 = q(1);
    q2 = q(2);
    dq1 = dq(1);
    dq2 = dq(2);
    l1 = a1/2;
    l2 = a2/2;
    
    C = C_fun(a1,dq1,dq2,l2,m2,q2);
