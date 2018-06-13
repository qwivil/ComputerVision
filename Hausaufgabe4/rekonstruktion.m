function [T, R, lambda, P1, camC1, camC2] = rekonstruktion(T1, T2, R1, R2, Korrespondenzen, K)
    %% Preparation
    T_cell = {T1, T2, T1, T2};
    R_cell = {R1, R1, R2, R2};
    
    N = size(Korrespondenzen,2);
    
    x1 = [Korrespondenzen(1:2,:); ones(1,N)];
    x1 = K\x1;
    
    x2 = [Korrespondenzen(3:4,:); ones(1,N)];
    x2 = K\x2;
    
    d_subcell = zeros(N,2);
    d_cell = {d_subcell d_subcell d_subcell d_subcell};
    
    %% Rekonstruktion Gleichungssysteme
    M1_R1T1 = M1_erstellen(R_cell{1}, T_cell{1}, N, x1, x2);
    M1_R1T2 = M1_erstellen(R_cell{1}, T_cell{2}, N, x1, x2);
    M1_R2T1 = M1_erstellen(R_cell{3}, T_cell{1}, N, x1, x2);
    M1_R2T2 = M1_erstellen(R_cell{3}, T_cell{2}, N, x1, x2);
    
    M2_R1T1 = M2_erstellen(R_cell{1}, T_cell{1}, N, x1, x2);
    M2_R1T2 = M2_erstellen(R_cell{1}, T_cell{2}, N, x1, x2);
    M2_R2T1 = M2_erstellen(R_cell{3}, T_cell{1}, N, x1, x2);
    M2_R2T2 = M2_erstellen(R_cell{3}, T_cell{2}, N, x1, x2);
    
    M1 = M1_R2T2;
    M2 = M2_R2T2;
    
    d1_R1T1 = d_erstellen(M1_R1T1);
    d1_R1T2 = d_erstellen(M1_R1T2);
    d1_R2T1 = d_erstellen(M1_R2T1);
    d1_R2T2 = d_erstellen(M1_R2T2);
    
    d2_R1T1 = d_erstellen(M2_R1T1);
    d2_R1T2 = d_erstellen(M2_R1T2);
    d2_R2T1 = d_erstellen(M2_R2T1);
    d2_R2T2 = d_erstellen(M2_R2T2);
    
    d_cell = {[d1_R1T1(1:N,1) d2_R1T1(1:N,1)], [d1_R1T2(1:N,1) d2_R1T2(1:N,1)], [d1_R2T1(1:N,1) d2_R2T1(1:N,1)], [d1_R2T2(1:N,1) d2_R2T2(1:N,1)]};
    
    pos_num(1) = count(d_cell{1});
    pos_num(2) = count(d_cell{2});
    pos_num(3) = count(d_cell{3});
    pos_num(4) = count(d_cell{4});
    
    [~, index] = max(pos_num);
    T = T_cell{index};
    R = R_cell{index};
    lambda = d_cell{index};
    
    %% Darstellung
    lambda1 = [lambda(:,1), lambda(:,1),lambda(:,1)]; 
    P1 = x1.*lambda1';
    
    for i = 1:N
        scatter3(P1(1,i), P1(2,i), P1(3,i));
        xlabel('X');
        ylabel('Y');
        zlabel('Z');
        grid on
        text(P1(1,i)+0.01, P1(2,i)+0.01, P1(3,i), num2str(i));
        hold on
    end
    
    camC1 = [-0.2  0.2  0.2 -0.2;
              0.2  0.2 -0.2 -0.2;
              1    1    1    1  ];
    camC2 = R\(camC1-T);
    
    plot3(camC1(1,:), camC1(2,:), camC1(3,:), 'b');
    plot3(camC2(1,:), camC2(2,:), camC2(3,:), 'r');
    
    campos([43 -22 -87]);
    camup([0 -1 0]);
end

function M1 = M1_erstellen(R, T, N, x1, x2)
    M1 = zeros(3*N,N+1);
    for i = 1:N
        M1(3*i-2:3*i, i) = cross(x2(:,i),R*x1(:,i));
        M1(3*i-2:3*i, N+1) = cross(x2(:,i),T);
    end
end

function M2 = M2_erstellen(R, T, N, x1, x2)
    M2 = zeros(3*N,N+1);
    for i = 1:N
        M2(3*i-2:3*i, i) = cross(x1(:,i),R'*x2(:,i));
        M2(3*i-2:3*i, N+1) = -cross(x1(:,i),R'*T);
    end
end

function d = d_erstellen(M)
    [~,~,V] = svd(M);
    d = V(:,end);
    d = d./d(end,1);
end

function pos_num = count(d_cell)
    count = find(d_cell>0);
    pos_num = length(count);
end