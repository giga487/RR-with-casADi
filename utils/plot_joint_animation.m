function plot_joint_animation(par,q)

    l1 = par(1,1);
    l2 = par(1,2);

    t_max = size(q,2);
    
    figure;

    for t = 1:5:t_max
        clf;
        x1 = q(1,t);
        x2 = q(2,t);
    
        M(1).m = matrixDH(l1,0,0,x1);
        M(2).m = matrixDH(l1,0,0,x1)*matrixDH(l2,0,0,x2);

        for i = 1:1:size(q,1)
            p(i).x = M(i).m(1,4);
            p(i).y = M(i).m(2,4);
        end

        hold on;
        plot([0 p(1).x], [0 p(1).y], 'k');
        plot([p(1).x p(2).x], [p(1).y p(2).y], 'k');

        viscircles([0,0],0.01);
        text(0+0.1,0.1,'q_0') 
        for i = 1:1:size(q,1)
            viscircles([p(i).x , p(i).y],0.01);
            label = sprintf('q_%i',i);
            text(p(i).x+0.1,p(i).y+0.1,label) 
        end
        viscircles([p(end).x , p(end).y],0.01);

        title('RR planare');
        axis equal
        pause(0.001);
    end

end