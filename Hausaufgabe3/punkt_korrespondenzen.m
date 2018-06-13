function Korrespondenzen = punkt_korrespondenzen(I1,I2,Mpt1,Mpt2,varargin)
    % In dieser Funktion sollen die extrahierten Merkmalspunkte aus einer
    % Stereo-Aufnahme mittels NCC verglichen werden um Korrespondenzpunktpaare
    % zu ermitteln.
    
    %% Input parser
    p = inputParser;
    
    %zwei Grauwert-Bilder I1, I2, zwei Merkmalspunktmatrizen Mpt1, Mpt2
    p.addRequired('I1');
    p.addRequired('I2');    
    p.addRequired('Mpt1');    
    p.addRequired('Mpt2');
    
    defaultwindow_length = 25; %窗口长度
    p.addOptional('window_length', defaultwindow_length, @(x) isnumeric(x) && (x > 1) && (mod(x,2) ~= 0));
    defaultmin_corr = 0.95; %阈值
    p.addOptional('min_corr', defaultmin_corr, @(x) isnumeric(x) && (x >= 0) && (x <= 1));
    defaultdo_plot = false;
    p.addOptional('do_plot', defaultdo_plot, @(x) islogical(x));
    
    p.parse(I1,I2,Mpt1,Mpt2,varargin{:});
    
    window_length = p.Results.window_length;
    min_corr = p.Results.min_corr;
    do_plot = p.Results.do_plot;
    Im1 = double(I1);
    Im2 = double(I2);
    
    %Korrespondenzen = {window_length, min_corr, do_plot, Im1, Im2}
    
    %% Merkmalsvorbereitung
    %删除距离边缘小于window_length/2的特征点
    %Mpt1和Mpt2是Harris检测出来的特征点
    %merkmale(:,all(merkmale==0,1)) = []; 删除全为0的一列
    [row1,col1] = size(I1);
    [row2,col2] = size(I2);
    
    Mpt1(1,Mpt1(1,:) < ceil((1/2)*window_length)) = 0;
    Mpt1(1,Mpt1(1,:) > col1-ceil((1/2)*window_length)) = 0;
    Mpt1(2,Mpt1(2,:) < ceil((1/2)*window_length)) = 0;
    Mpt1(2,Mpt1(2,:) > row1-ceil((1/2)*window_length)) = 0;
    Mpt1(:,any(Mpt1==0,1)) = [];
    
    Mpt2(1,Mpt2(1,:) < ceil((1/2)*window_length)) = 0;
    Mpt2(1,Mpt2(1,:) > col2-ceil((1/2)*window_length)) = 0;
    Mpt2(2,Mpt2(2,:) < ceil((1/2)*window_length)) = 0;
    Mpt2(2,Mpt2(2,:) > row2-ceil((1/2)*window_length)) = 0;
    Mpt2(:,any(Mpt2==0,1)) = [];
    
    no_pts1 = size(Mpt1,2);
    no_pts2 = size(Mpt2,2);
    
    %Korrespondenzen = {no_pts1, no_pts2, Mpt1, Mpt2};
    
    %% Normierung
    %平均值mean(M(:))，标准差std(M(:))
    for i = 1:length(Mpt1)
        norm_fenster1 = double(I1(Mpt1(2,i)-floor((1/2)*window_length):Mpt1(2,i)+floor((1/2)*window_length),Mpt1(1,i)-floor((1/2)*window_length):Mpt1(1,i)+floor((1/2)*window_length)));
        mean1 = mean(norm_fenster1(:));
        std1 = std(norm_fenster1(:));
        norm_fenster1 = (1/std1)*(norm_fenster1 - mean1);
        Mat_feat_1(:,i) = reshape(norm_fenster1,[window_length*window_length,1]);
    end
    
    for i = 1:length(Mpt2)
        norm_fenster2 = double(I2(Mpt2(2,i)-floor((1/2)*window_length):Mpt2(2,i)+floor((1/2)*window_length),Mpt2(1,i)-floor((1/2)*window_length):Mpt2(1,i)+floor((1/2)*window_length)));
        mean2 = mean(norm_fenster2(:));
        std2 = std(norm_fenster2(:));
        norm_fenster2 = (1/std2)*(norm_fenster2 - mean2);
        Mat_feat_2(:,i) = reshape(norm_fenster2,[window_length*window_length,1]);
    end
    
    %Korrespondenzen = {Mat_feat_1, Mat_feat_2};
    
    %% NCC Brechnung
     
    NCC_matrix = (1/(window_length^2-1))*Mat_feat_2'*Mat_feat_1;
     
    NCC_matrix(NCC_matrix < min_corr) = 0;
    [sorted, sorted_index] = sort(NCC_matrix(:),'descend');
    
    sorted_index(sorted==0)=[];
     
    %Korrespondenzen = {NCC_matrix, sorted_index};
    
    %% Korrespondenz
    Korrespondenzen = zeros(4,numel(sorted_index));
    count = 1;
    for i=1:numel(sorted_index)
        current = sorted_index(i);
        x_NCC_matrix = ceil(current/size(NCC_matrix,1));
        y_NCC_matrix = current-(x_NCC_matrix-1)*size(NCC_matrix,1);
        if any(Mat_feat_1(:,x_NCC_matrix)~=0) && any(Mat_feat_2(:,y_NCC_matrix)~=0) %why there are not right, if the point in bild2 is already korrespondt, there will be 2 to 1??? run this example, left bottom
            Korrespondenzen(:,count) = [Mpt1(1,x_NCC_matrix);Mpt1(2,x_NCC_matrix);Mpt2(1,y_NCC_matrix);Mpt2(2,y_NCC_matrix)];
            count = count+1;
            
            Mat_feat_1(:,x_NCC_matrix) = 0;
            Mat_feat_2(:,y_NCC_matrix) = 0;            
        else 
            continue
        end 
    end
    Korrespondenzen(:,all(Korrespondenzen==0,1)) = [];
    
    %% Zeige die Korrespondenzpunktpaare an
    if do_plot
        Korrespondenzen=sortrows(Korrespondenzen',[1,2])';
        c = jet(size(Korrespondenzen,2));
        add = I1+I2*0.5;
        figure;
        imshow(add);
        hold on;
        for i=1:size(Korrespondenzen,2)
            plot(Korrespondenzen(1,i),Korrespondenzen(2,i),'o','color',c(i,:))
            text(Korrespondenzen(1,i)+10,Korrespondenzen(2,i)+5,num2str(i),'color',c(i,:))
            plot(Korrespondenzen(3,i),Korrespondenzen(4,i),'o','color',c(i,:))
            text(Korrespondenzen(3,i)+10,Korrespondenzen(4,i)+5,num2str(i),'color',c(i,:))
            line(Korrespondenzen([1,3],i),Korrespondenzen([2,4],i),'color',c(i,:))
        end
    end
end