function [Korrespondenzen_robust] = F_ransac(Korrespondenzen, varargin)
    % Diese Funktion implementiert den RANSAC-Algorithmus zur Bestimmung von
    % robusten Korrespondenzpunktpaaren
    
    %% Input parser
    p = inputParser;
    
    p.addRequired('Korrespondenze');
    
    defaultepsilon = 0.5;
    p.addOptional('epsilon', defaultepsilon, @(x) isnumeric(x) && (x>0) && (x<1));
    
    defaultp = 0.5;
    p.addOptional('p', defaultp, @(x) isnumeric(x) && (x>0) && (x<1));
    
    defaulttolerance = 0.01;
    p.addOptional('tolerance', defaulttolerance, @(x) isnumeric(x));
    
    p.parse(Korrespondenzen, varargin{:});
    
    epsilon = p.Results.epsilon;
    tolerance = p.Results.tolerance;
    p = p.Results.p;
    
    x1_pixel = [Korrespondenzen(1:2,:);ones(1,size(Korrespondenzen(1:2,:),2))];
    x2_pixel = [Korrespondenzen(3:4,:);ones(1,size(Korrespondenzen(3:4,:),2))];
    
    %% RANSAC Algorithmus Vorbereitung
    k = 8;
    s = ceil(log(1-p)/log(1-(1-epsilon)^k));
    largest_set_size = 0;
    largest_set_dist = inf;
    largest_set_F = zeros(3,3);
    
    %% RANSAC Algorithmus
    for i=1:s
        consensus_sets = Korrespondenzen(:,randperm(size(Korrespondenzen,2), k));
        
        [EF] = achtpunktalgorithmus(consensus_sets);
        sd = sampson_dist(EF, x1_pixel, x2_pixel);
        sd = sd(sd<tolerance);
        set_size = size(sd,2);
        
        if set_size > largest_set_size
            largest_set_size = set_size;
            largest_set_dist = sum(sd);
            largest_set_F = EF;
            Korrespondenzen_robust = consensus_sets;
        end
        if set_size == largest_set_size
            if sum(sd) < largest_set_dist
                largest_set_size = set_size;
                largest_set_dist = sum(sd);
                largest_set_F = EF;
                Korrespondenzen_robust = consensus_sets;
            end
        end
    end 
    Korrespondenzen_robust = {Korrespondenzen_robust, largest_set_F};
end