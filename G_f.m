function G = G_f(parameter,q)
    
    a1 = parameter(1,1);
    a2 = parameter(2,2);
    m1 = parameter(1,2);
    m2 = parameter(2,2);
       
    q1 = q(1);
    q2 = q(2);
    
    g0 = 9.81;
    
    l1 = a1/2;
    l2 = a2/2;
    
    G = G_fun(a1,g0,l1,l2,m1,m2,q1,q2);
