function [repro_error, x2_repro] = rueckprojektion(Korrespondenzen, P1, Image2, T, R, K)
    % Diese Funktion berechnet den mittleren Rueckprojektionsfehler der 
    % Weltkooridnaten P1 aus Bild 1 im Cameraframe 2 und stellt die 
    % korrekten Merkmalskoordinaten sowie die rueckprojezierten grafisch dar.
    
    P2 = R*P1+T; %Weltkoordinaten in Cameraframe 2,相机和相的移动是相反的
    x2_berechnen = K*P2;
    x2_repro = x2_berechnen./x2_berechnen(3,:);
    imshow(Image2);
    x2 = Korrespondenzen(3:4,:);
    hold on
    N = size(x2,2);
    for i=1:N
        plot(x2(1,i),x2(2,i),'o');
        text(x2(1,i)+10, x2(2,i), num2str(i));
        plot(x2_repro(1,i),x2_repro(2,i),'x');
        text(x2_repro(1,i)+10, x2_repro(2,i), num2str(i));
    end
    
    repro_error = (1/N)*sum(sqrt((sum((x2-x2_repro(1:2,:)).^2)')'));
end