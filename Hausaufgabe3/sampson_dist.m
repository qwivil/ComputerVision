function sd = sampson_dist(F, x1_pixel, x2_pixel)
    % Diese Funktion berechnet die Sampson Distanz basierend auf der
    % Fundamentalmatrix F
    e3_hat = [0 -1 0;
              1  0 0;
              0  0 0];     
    numerator = sum((x2_pixel'*F)'.*x1_pixel,1).^2;
    denominator = (sum((e3_hat*F*x1_pixel).^2,1)+sum((x2_pixel'*F*e3_hat).^2,2)');
    sd = numerator./denominator;
end
