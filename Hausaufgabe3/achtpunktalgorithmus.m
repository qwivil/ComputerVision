function [EF] = achtpunktalgorithmus(Korrespondenzen, K)
    % Diese Funktion berechnet die Essentielle Matrix oder Fundamentalmatrix
    % mittels 8-Punkt-Algorithmus, je nachdem, ob die Kalibrierungsmatrix 'K'
    % vorliegt oder nicht
    
    x1 = Korrespondenzen(1:2,:);
    x1 = [x1;ones(1,size(x1,2))];
    x2 = Korrespondenzen(3:4,:);
    x2 = [x2;ones(1,size(x2,2))];
    
    if exist('K','var')
        x1 = K^-1*x1;
        x2 = K^-1*x2;
    end
    
    A = [x1(1,:).*x2(1,:);
         x1(1,:).*x2(2,:);
         x1(1,:);
         x1(2,:).*x2(1,:);
         x1(2,:).*x2(2,:);
         x1(2,:);
         x2]';
    [~,~,V]=svd(A);
    
    G=reshape(V(:,9),3,3);
    
    [U_g,S_g,V_g]=svd(G);
    
    if exist('K','var')
        EF=U_g*diag([1,1,0])*V_g';
    else
        EF=U_g*diag([S_g(1,1),S_g(2,2),0])*V_g';
    end

end