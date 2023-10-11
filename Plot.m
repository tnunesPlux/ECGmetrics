
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

Ag_electrodes = Data(:,3); % First acquired channel
Dry_Graphene_electrodes = Data(:,4); % Second acquired channel

% Sensor Power Supply in Volts
Vcc = 3;

% ADC Resolution in Bits
resolution = 16;

% ECG Sensor Gain
SensorGain = 1019;

% Time analysis window in seconds (s)
timeEnd = 8; % Indicate the last moment that you want to vizualise

timeAxis = 1:length(Ag_electrodes);

%% Transfer Function to get values in mV
% ECG(mV) = ((ADC/2^Resolution - 0,5)*Vcc ) / Gain * 1000
% Multiply by 1000 to convert V in mV

% Convert RAW values in mV
Ag_electrodes_mV = ((Ag_electrodes ./ (2^resolution)) - 0.5) .* Vcc ./SensorGain .*1000;
Dry_Graphene_electrodes_mV = ((Dry_Graphene_electrodes ./ (2^resolution)) - 0.5) .* Vcc ./SensorGain .*1000;

% Voltage axis
figure (1);
% plot(timeAxis,Ag_electrodes_mV(timeAxis));
% hold on;
plot(timeAxis, Dry_Graphene_electrodes_mV(timeAxis),'r');
xlabel('Sample ');
ylabel('ECG (mV)');
title('Real acquisition');
legend('Ag/AgCl', 'Dry Electrodes');

%% Normalize values

% Get mean value, 'u'

u_Ag = mean(Ag_electrodes_mV(timeAxis));
u_Dry = mean(Dry_Graphene_electrodes_mV(timeAxis));

Ag_norm = ones(length(Ag_electrodes_mV(timeAxis)), 1);
Dry_norm = ones(length(Dry_Graphene_electrodes_mV(timeAxis)), 1);

MA_Ag = max(Ag_electrodes_mV(timeAxis));
MI_Ag = min(Ag_electrodes_mV(timeAxis));

MA_Dry = max(Dry_Graphene_electrodes_mV(timeAxis));
MI_Dry = min(Dry_Graphene_electrodes_mV(timeAxis));

for i = 1:length(timeAxis)
    Ag_norm(i) = (Ag_electrodes_mV(i) - u_Ag) / ( MA_Ag - MI_Ag);
    Dry_norm(i) = (Dry_Graphene_electrodes_mV(i) - u_Dry) / ( MA_Dry - MI_Dry);
end

% figure(2);
% plot(timeAxis,Ag_norm(timeAxis));
% hold on;
% plot(timeAxis, Dry_norm(timeAxis),'r');

xlabel('Time (s)');
ylabel('ECG (mV)');
title('Normalized scale');

%% Local Maxima - R-peaks
sample = Dry_Graphene_electrodes_mV(timeAxis);

[TF, P] = islocalmax(sample);
Max = P > 0.5;
hold on;    
plot(timeAxis(Max), sample(Max), 'ko') ;

legend('Ag/AgCl Normalized', 'Dry Electrodes Normalized', 'R-peaks');

%% Plot Segment

% Get a_b window:
% a = 'R' peak minus 200ms: R - 0,2 * Freq
% b = 'R' peak plus 400ms: R + 0,4 * Freq

figure (3);

R_peaks = timeAxis(Max);

a_lim = R_peaks - 0.2 * samplingFreq;

b_lim = R_peaks + 0.4 * samplingFreq;

Seg_size = 0.6*samplingFreq + 1; % 0.6s

RMSE = zeros(1,length(a_lim));

for i = 1:length(RMSE)
    Dry_Seg = Dry_norm(a_lim(i):b_lim(i));
    plot(Dry_Seg, 'b');
    hold on;
    Ag_Seg = Ag_norm(a_lim(i):b_lim(i));
    plot(Ag_Seg, 'r');
    RMSE(i) = sqrt( sum( (Dry_Seg - Ag_Seg).^2 ) / Seg_size);
%     hold off;
    title('Segment comparison');
    legend('Ag/AgCl', 'Dry Electrodes');
end

fprintf('RMSE mean is: %f\n', mean(RMSE));
fprintf('RMSE std is: %f\n', std(RMSE));
