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
    
    p.parse(input_image, varargin{:});
    
    
    segment_length = p.Results.segment_length;
    k = p.Results.k;
    tau = p.Results.tau;
    do_plot = p.Results.do_plot;
   
    merkmale = {segment_length, k, tau, do_plot};
    
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
    
    % Harris Matrix G
    G11 = conv2(w,w,Ix.^2,'same');
    G22 = conv2(w,w,Iy.^2,'same');
    G12 = conv2(w,w,Ix.*Iy,'same');
    
    %merkmale = {Ix, Iy, w, G11, G22, G12}
    
    %% Merkmalsextraktion ueber die Harrismessung
    H = ((G11.*G22 - G12.^2) - k*(G11 + G22).^2);
    mask=zeros(size(H));
    mask((ceil(segment_length/2)+1):(size(H,1)-ceil(segment_length/2)),(ceil(segment_length/2)+1):(size(H,2)-ceil(segment_length/2)))=1;
    R = H.*mask;

    R(R<tau)=0;
    [row,col] = find(R); 
    corners = R;
    merkmale = [col,row]'; 
    
    
    merkmale = {H, corners, merkmale};
    
    %% Plot
    
    if p.Results.do_plot == true
        figure
        imshow(input_image);
        hold on
        for i = 1:size(col)
            plot(row(i),col(i),'o');            
        end
    end

    
end