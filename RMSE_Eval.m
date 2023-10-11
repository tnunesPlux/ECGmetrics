function [RMSE_sum, RMSE_n] = RMSE_Eval(limits, Ag_electrodes, Dry_electrodes, samplingFreq)

    RMSE_table = zeros(length(Ag_electrodes), 2);
    
    time = 1 : length(Ag_electrodes) ;
    
    % Local Maxima - R-peaks
    figure(1);
    hold off;
    plot(time, Ag_electrodes) ;
    hold on;
    
    [TF, P] = islocalmax(Ag_electrodes);
    Max = P > 0.5;
    
    plot(time(Max), Ag_electrodes(Max), 'ko') ;
    
    %% Plot Segment
    
    % Get a_b window:
    % a = 'R' peak minus 200ms: R - 0,2 * Freq
    % b = 'R' peak plus 400ms: R + 0,4 * Freq
    
    R_peaks = time(Max);
    
    a_lim = R_peaks - 0.2 * samplingFreq;
    
    b_lim = R_peaks + 0.4 * samplingFreq;
    
    Seg_size = 0.6*samplingFreq + 1; % 0.6s
    
    RMSE = zeros(1,length(R_peaks));
    figure (2);
    for i = 1:length(R_peaks)
        Dry_QRS = Dry_electrodes(a_lim(i):b_lim(i));
        plot(Dry_QRS);
        hold on;
        Ag_QRS = Ag_electrodes(a_lim(i):b_lim(i));
        plot(Ag_QRS);
        hold off;
        title('Segment comparison');
        legend('Ag/AgCl', 'Dry Electrodes');
    
        RMSE(i) = sqrt( sum( (Dry_QRS - Ag_QRS).^2 ) / Seg_size);
    end
    
    RMSE_table(segment, 1) = sum(RMSE);
    RMSE_table(segment, 2) = length(RMSE);


end