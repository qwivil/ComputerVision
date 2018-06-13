function gray_image = rgb_to_gray(input_image)
    % Diese Funktion soll ein RGB-Bild in ein Graustufenbild umwandeln. Falls
    % das Bild bereits in Graustufen vorliegt, soll es direkt zurueckgegeben werden.
    [a,b,c]=size(input_image);
    if c == 3
        r = double(input_image(:,:,1));  %通道R  
        g = double(input_image(:,:,2));  %通道G  
        b = double(input_image(:,:,3));  %通道B
        gray_image = uint8(0.299 * r + 0.587 * g + 0.114 * b);
    else 
        gray_image = input_image;
end