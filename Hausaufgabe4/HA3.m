%% Bilder laden
Image1 = imread('szeneL.png');
IGray1 = rgb_to_gray(Image1);
Image2 =imread('szeneR.png');
IGray2 = rgb_to_gray(Image2);


%% Harris-Merkmale berechnen
Merkmale1 = harris_detektor(IGray1,'segment_length',9,'k',0.05,'min_dist',40,'N',50,'do_plot',false);
Merkmale2 = harris_detektor(IGray2,'segment_length',9,'k',0.05,'min_dist',40,'N',50,'do_plot',false);

%% Korrespondenzschätzung
Korrespondenzen = punkt_korrespondenzen(IGray1,IGray2,Merkmale1,Merkmale2,'window_length',25,'min_corr',0.9,'do_plot',false);

%%  Finde robuste Korrespondenzpunktpaare mit Hilfe des RANSAC-Algorithmus
Korrespondenzen_robust = F_ransac(Korrespondenzen, 'tolerance', 0.04);

%% Zeige die robusten Korrespondenzpunktpaare

Korrespondenzen_robust=sortrows(Korrespondenzen_robust{1,1}',[1,2])';
c = jet(size(Korrespondenzen_robust,2));
add = IGray1+IGray2*0.5;
figure;
imshow(add);
hold on;
for i=1:size(Korrespondenzen_robust,2)
    plot(Korrespondenzen_robust(1,i),Korrespondenzen_robust(2,i),'o','color',c(i,:))
    text(Korrespondenzen_robust(1,i)+10,Korrespondenzen_robust(2,i)+5,num2str(i),'color',c(i,:))
    plot(Korrespondenzen_robust(3,i),Korrespondenzen_robust(4,i),'o','color',c(i,:))
    text(Korrespondenzen_robust(3,i)+10,Korrespondenzen_robust(4,i)+5,num2str(i),'color',c(i,:))
    line(Korrespondenzen_robust([1,3],i),Korrespondenzen_robust([2,4],i),'color',c(i,:))
end

%% Berechne die Essentielle Matrix
%load('K.mat');
E = achtpunktalgorithmus(Korrespondenzen);
disp(E);