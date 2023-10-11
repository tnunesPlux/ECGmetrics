
close all;

%% Open document

filename = 'Compare_signals\acq_1.txt'; %Enter the name of the file to be analysed and its extension (.txt)

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

% getSegments(Ag_electrodes, Dry_Graphene_electrodes);
limits_1 = [1,3200;27588,49533;51573,53329;56384,66659];
limits_2 = [42567,47475;60084,75181;78137,120976;125864,172369;177698,232002;237064,267221];
limits_3 = [15841,48257;66923,100684;105821,125677;140084,175707;183089,233769;247064,276813;283897,308743;337077,360505];
limits_4 = [10287, 16067;24777,85224;96194,109540;115289,139200;151646,175010;176493,180327;181722,187929;189025,196320;197461,201070;203034,204886;207882,210831;218400,230434;237940,247891;273635,302647;309157,322174;323331,336362;341223,361213;377180,389423;391392,399457;406095,458475;485629,515277;527809,544784;586914,606403;611205,632321;633955,641646;644138,668474;708077,749075;750505,771425;772849,784458;792430,834094;918085,943417;945522,968520;999294,1010430;1018940,1026780];
limits_5 = [89302,153866;156729,185860;190157,209761;232673,309269;312042,325051;330916,369818;380639,407299;460912,494918;496590,717331;770338,805444;812431,859885;902815,949395;956239,982855;985669,1009050;1013500,1042060;1080360,1146940;1181360,1246570];

limits = limits_1;

RMSE_table = zeros(length(limits), 2);
delete("RMSE.txt");

plot(Ag_electrodes);

for portion = 1:length(limits)
    
    timeAxis = 1:(limits(portion, 2) - limits(portion, 1) + 1);
    
    % Extract values associated with time axis
    idx = limits(portion, 1) : limits(portion, 2);
    Ag_portion = Ag_electrodes(idx);
    Dry_portion = Dry_Graphene_electrodes(idx);
    
    
    figure (1);
    hold off;
    plot(timeAxis,Ag_portion);
    hold on;
    plot(timeAxis,Dry_portion,'r');
    xlabel('Sample ');
    
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
    
    figure(2);
    hold off;
    plot(timeAxis,Ag_norm(timeAxis));
    hold on;
    plot(timeAxis, Dry_norm(timeAxis),'r');


    % Local Maxima - R-peaks
    [TF, P] = islocalmax(Ag_norm);
    Max = P > 0.5;
    hold on;    
    plot(timeAxis(Max), Ag_norm(Max), 'ko') ;

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
        figure (3)
        Dry_Seg = Dry_norm(a_lim(i):b_lim(i));
        pDry = plot(Dry_Seg, 'b', 'LineWidth',1);
        hold on;
        Ag_Seg = Ag_norm(a_lim(i):b_lim(i));
        pAg = plot(Ag_Seg, 'r', 'LineWidth',1);
        RMSE(i) = sqrt( sum( (Dry_Seg - Ag_Seg).^2 ) / Seg_size);
        writelines(string(RMSE(i)), "RMSE.txt", LineEnding = "\n", WriteMode = "append");
        hold off;
        title('Segment comparison');
        legend('Ag/AgCl', 'Dry Electrodes');

        figure (4)
        title('Average segment');
        pDry = plot(Dry_Seg, 'b', 'LineWidth',0.5,'HandleVisibility','off');
        hold on;
        pAg = plot(Ag_Seg, 'r', 'LineWidth',0.5,'HandleVisibility','off');
        pDry.Color(4) = 0.1;
        pAg.Color(4) = 0.1;
       

        figure (4+portion);
        subplot(1, 2, 1);
        p1 = plot(Dry_Seg, 'b', 'LineWidth',2);
        hold on;
        subplot(1, 2, 2);
        p2 = plot(Ag_Seg, 'r', 'LineWidth',2);
        hold on;
        figure(10);
        subplot(1, 2, 1);
        p1 = plot(Dry_Seg, 'b', 'LineWidth',1);
        hold on;
        subplot(1, 2, 2);
        p2 = plot(Ag_Seg, 'r', 'LineWidth',1);
        hold on;
        p1.Color(4)=0.1;
        p2.Color(4)=0.1;

    end
    RMSE_table(portion, :) = [sum(RMSE), length(RMSE)];
    fprintf('RMSE mean of portion %d is: %f\n', portion, mean(RMSE));

end

figure (4)
h = zeros(2, 1);
h(1) = plot(NaN,NaN,'-b');
h(2) = plot(NaN,NaN,'-r');
legend(h, 'Dry Electrodes','Ag/AgCl Electrodes');

Final_RMSE = sum(RMSE_table(:, 1))/sum(RMSE_table(:, 2))

RMSE_values = importdata("RMSE.txt");

mean(RMSE_values);
std(RMSE_values);

fprintf('RMSE of signal is: \n %f+-%f\n',  mean(RMSE_values), std(RMSE_values));
fprintf('Sample size: %d\n', length(RMSE_values));
