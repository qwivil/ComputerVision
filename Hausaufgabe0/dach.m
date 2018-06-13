function W = dach(w)
    % Diese Funktion implementiert den ^-Operator.
    % Sie wandelt einen 3-Komponenten Vektor in eine
    % schiefsymetrische Matrix um.
    [r,c]=size(w);
    if r == 3 & c ==1    
        temp = w';
        W = zeros(3,3);
        W(1,2) = -temp(3);
        W(1,3) = temp(2);
        W(2,1) = temp(3);
        W(2,3) = -temp(1);
        W(3,1) = -temp(2);
        W(3,2) = temp(1);
    else 
        error('Variable w muss ein 3-Komponenten Vektor sein!')
    end

end