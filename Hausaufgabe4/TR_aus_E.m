function [T1, R1, T2, R2, U, V]=TR_aus_E(E)
    % Diese Funktion berechnet die moeglichen Werte fuer T und R
    % aus der Essentiellen Matrix
    [U,S,V] = svd(E);
    U = U * [1 0 0; 0 1 0; 0 0 -1];
    V = V * [1 0 0; 0 1 0; 0 0 -1]; %don't know why should i do this?
    R_zp = [0 -1  0;
           1  0  0;
           0  0  1];
    R_zm = [ 0  1  0;
           -1  0  0;
            0  0  1];   
       
    R1 = U*R_zp'*V';
    R2 = U*R_zm'*V';
    
    T1_hat = U*R_zp*S*U';
    T1 = [T1_hat(3,2);
          T1_hat(1,3);
          T1_hat(2,1)];
    T2_hat = U*R_zm*S*U';
    T2 = [T2_hat(3,2);
          T2_hat(1,3);
          T2_hat(2,1)];
end