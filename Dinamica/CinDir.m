function K = CinDir(q,parameter)

    K = matrixDH(parameter(1,1),0,0,q(1))*matrixDH(parameter(1,2),0,0,q(2));

end
