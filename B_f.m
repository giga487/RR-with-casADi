function B = B_f(parameter,q)
    
    a1 = parameter(1,1);
    a2 = parameter(2,1);
    m1 = parameter(1,2);
    m2 = parameter(2,2);
    
    q1 = q(1);
    q2 = q(2);
    
    l1 = a1/2;
    l2 = a2/2;
    
    B = B_fun(a1,l1,l2,m1,m2,q2);