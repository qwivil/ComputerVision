Image2 = imread('szeneR.png');
IGray2 = rgb_to_gray(Image2);

[repro_error, ~] = rueckprojektion(Korrespondenzen_robust, P1, IGray2, T, R, K);