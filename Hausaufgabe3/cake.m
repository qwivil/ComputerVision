function Cake = cake(min_dist)
    % Die Funktion cake erstellt eine "Kuchenmatrix", die eine kreisfoermige
    % Anordnung von Nullen beinhaltet und den Rest der Matrix mit Einsen
    % auffuellt. Damit koennen, ausgehend vom staerksten Merkmal, andere Punkte
    % unterdrueckt werden, die den Mindestabstand hierzu nicht einhalten. 
    % min_dist: ist der minimale Pixelabstand zweier Merkmale (Standardwert: 20)
    [X,Y]=meshgrid(-min_dist:min_dist,-min_dist:min_dist);
    Cake=sqrt(X.^2+Y.^2)>min_dist;
end