

function q_d = invCin(parameter,p)

    q_d = size(2,1);
    m1 = parameter(2,1);
    m2 = parameter(2,2);
    a1 = parameter(1,1);
    a2 = parameter(1,2);
    x = p(1,1);
    y = p(2,1);
    
    
    c2 = (x^2+y^2-a1^2-a2^2)/(2*a1*a2);
    s2 = sqrt(1-c2);

    q_d2 = atan2(s2,c2);
    q_d1 = atan2(y,x)-atan2(a2*s2,a1+a2*c2);
        
    q_d = [q_d1,q_d2];
    
end