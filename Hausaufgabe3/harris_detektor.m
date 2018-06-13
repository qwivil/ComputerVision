function merkmale = harris_detektor(input_image, varargin)
    % In dieser Funktion soll der Harris-Detektor implementiert werden, der
    % Merkmalspunkte aus dem Bild extrahiert
    
    %% Input parser
    p = inputParser;
    
    p.addRequired('input_image');
    
    defaultsegment_length = 15;
    p.addOptional('segment_length',defaultsegment_length, @(x) isnumeric(x) && (x > 1) && (mod(x,2)~=0));
    
    defaultk = 0.05;
    p.addOptional('k', defaultk, @(x) (x >= 0) && isnumeric(x) && (x <= 1));
    
    defaulttau = 10^6;
    p.addOptional('tau', defaulttau, @(x) (x >= 0) && isnumeric(x));
    
    defaultdo_plot = false;
    p.addOptional('do_plot',defaultdo_plot, @(x) islogical(x));
    
    defaultmin_dist = 20;
    p.addOptional('min_dist', defaultmin_dist, @(x) isnumeric(x) && (x >= 1));
    
    defaulttile_size = [200, 200];
    p.addOptional('tile_size', defaulttile_size, @(x) isnumeric(x));
    
    defaultN = 5;
    p.addOptional('N', defaultN, @(x) isnumeric(x) && (x >= 1));
    
    p.parse(input_image, varargin{:});
    
    if length(p.Results.tile_size) == 2
        Results.tile_size = p.Results.tile_size;
    else 
        height = p.Results.tile_size;
        Results.tile_size = [height, 200];
    end
    
    segment_length = p.Results.segment_length;
    k = p.Results.k;
    tau = p.Results.tau;
    do_plot = p.Results.do_plot;
    min_dist = p.Results.min_dist;
    tile_size = Results.tile_size;
    N = p.Results.N;
    
    %% Vorbereitung zur Feature Detektion
    % Pruefe ob es sich um ein Grauwertbild handelt
    if size(input_image,3) ~= 1
        error('Image format has to be NxMx1');
    end
    
    % Approximation des Bildgradienten
    dgray = double(input_image);
    [Ix, Iy] = sobel_xy(input_image);
    
    % Gewichtung
    w = fspecial('gaussian',[1 segment_length],segment_length/5);
    W = w'*w;
    
    % Harris Matrix G
    G11 = conv2(Ix.^2,W,'same');
    G22 = conv2(Iy.^2,W,'same');
    G12 = conv2(Ix.*Iy,W,'same');
    
    %% Merkmalsextraktion ueber die Harrismessung
    H = ((G11.*G22 - G12.^2) - k*(G11 + G22).^2);
    mask=zeros(size(H));
    mask((ceil(segment_length/2)+1):(size(H,1)-ceil(segment_length/2)),(ceil(segment_length/2)+1):(size(H,2)-ceil(segment_length/2)))=1;
    R = H.*mask;
    R(R<tau)=0;
 
    [row,col] = find(R);
    corners = R;
    
    %% Merkmalsvorbereitung
    expand = zeros(size(corners)+2*min_dist);
    expand(min_dist+1:min_dist+size(corners,1),min_dist+1:min_dist+size(corners,2)) = corners;
    corners = expand;
    
    [sorted, sorted_index] = sort(corners(:),'descend');
    
    sorted_index(sorted==0)=[];
    
    %merkmale = {corners, sorted_index}
    
    %% Akkumulatorfeld
   
    AKKA = zeros(ceil(size(input_image,1)/tile_size(1)),ceil(size(input_image,2)/tile_size(2)));
    merkmale = zeros(2,min(numel(AKKA)*N,numel(sorted_index)));

    %merkmale = {AKKA, merkmale};
    
    %% Merkmalsbestimmung mit Mindestabstand und Maximalzahl pro Kachel
    Cake = cake(min_dist);
    count = 1;
    for i = 1:numel(sorted_index)
        current = sorted_index(i);
        if corners(current) == 0
            continue;
        else 
            x_corners = floor(current/size(corners,1));
            y_corners = current-x_corners*size(corners,1);
            x_corners = x_corners+1;
        end
            x_AKKA = ceil((x_corners-min_dist)/tile_size(2));
            y_AKKA = ceil((y_corners-min_dist)/tile_size(1));

            corners(y_corners-min_dist:y_corners+min_dist,x_corners-min_dist:x_corners+min_dist) = corners(y_corners-min_dist:y_corners+min_dist,x_corners-min_dist:x_corners+min_dist).*Cake;
           
        if AKKA(y_AKKA,x_AKKA) < N
            AKKA(y_AKKA,x_AKKA) = AKKA(y_AKKA,x_AKKA)+1;
            merkmale(:,count) = [x_corners-min_dist;y_corners-min_dist];
            count = count+1;
        end
    end
    merkmale(:,all(merkmale==0,1)) = [];
    
    % Plot Routine
    if do_plot == 1
        figure  
        colormap('gray')
        imagesc(input_image)
        hold on;
        plot(merkmale(1,:), merkmale(2,:), 'gs');
    end
    
  
end