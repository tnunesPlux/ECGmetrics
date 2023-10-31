%% Tiago Nunes, 2023
% Segment a ECG file with artifacts manually extracted

close all;

%% Open document

filename = '.\acq_1.txt'; %Enter the name of the file to be analysed and its extension (.txt)

delimiterIn = '\t'; %Specifies the delimiter (what divides two columns), in this case a tabulation

headerlinesIn = 3; %Number of Header lines to be ignored (comments with the name, characteristics, frequence...)

A = importdata(filename,delimiterIn,headerlinesIn); %Data is imported to a structure with the frame number and the acquired data
% It separates the headers from the data. In the structure outputted, 'data' contains the relevant data after the headers

samplingFreq = 400; % Frequence used for acquiring the signal

Data = A.data; % Get the data from the structure

% Acquired information is stored sequentially: First the digital channel,
% then the other ports per order

Ag_electrodes = Data(:,4); % First acquired channel
Dry_Graphene_electrodes = Data(:,3); % Second acquired channel

limits = [1,3200;27588,49533;51573,53329;56384,66659];

delete("ECG_segments.txt");
total_segments = 0;
for portion = 1:length(limits)
    
    timeAxis = 1:(limits(portion, 2) - limits(portion, 1) + 1);
    
    % Extract values associated with time axis
    idx = limits(portion, 1) : limits(portion, 2);
    Ag_portion = Ag_electrodes(idx);
    Dry_portion = Dry_Graphene_electrodes(idx);
      
    %% Normalize values
    
    % Get mean value, 'u', in the segment under analysis
    
    u_Ag = mean(Ag_portion);
    u_Dry = mean(Dry_portion);
    
    % Create variable to store normalized values
    Ag_norm = ones(length(Ag_portion), 1);
    Dry_norm = ones(length(Dry_portion), 1);
    
    MA_Ag = max(Ag_portion);
    MI_Ag = min(Ag_portion);
    
    MA_Dry = max(Dry_portion);
    MI_Dry = min(Dry_portion);
    
    for i = timeAxis
        Ag_norm(i) = (Ag_portion(i) - u_Ag) / ( MA_Ag - MI_Ag);
        Dry_norm(i) = (Dry_portion(i) - u_Dry) / ( MA_Dry - MI_Dry);
    end
    
    % Local Maxima - R-peaks
    [TF, P] = islocalmax(Ag_norm);
    Max = P > 0.5;
    hold on;    
    % plot(timeAxis(Max), Ag_norm(Max), 'ko') ;

    %% Plot Segment
    % Get a_b window:
    % a = 'R' peak minus 200ms: R - 0,2 * Freq
    % b = 'R' peak plus 400ms: R + 0,4 * Freq
    
    R_peaks = timeAxis(Max);
    
    a_lim = R_peaks - 0.2 * samplingFreq;
    b_lim = R_peaks + 0.4 * samplingFreq;
    
    % If the first peak is to close to the left border, we discard it
    if a_lim(1) < 1
        a_lim(1) = [];
        b_lim(1) = [];
    end
    
    % If the last peak is to close to the right border, we discard it
    if b_lim(end) > timeAxis(end)
        a_lim(end) = [];
        b_lim(end) = [];
    end

    Seg_size = 0.6*samplingFreq + 1; % 0.6s

    RMSE = zeros(1,length(a_lim));
    % Stores the RMSE of every individual QRS complex

    for i = 1:length(RMSE)
        Dry_Seg = Dry_norm(a_lim(i):b_lim(i));
        Ag_Seg = Ag_norm(a_lim(i):b_lim(i));
        
        Dry_Seg = Dry_Seg';
        Ag_Seg = Ag_Seg';

        writematrix(Dry_Seg, "ECG_segments.txt", LineEnding = "\n", WriteMode = "append", Delimiter="space");
        writematrix(Ag_Seg, "ECG_segments.txt", LineEnding = "\n", WriteMode = "append", Delimiter="space");

        total_segments = total_segments + 2;
    end
end
fprintf('Total number of segments is %d.\n', total_segments);