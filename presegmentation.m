close all;

filename = 'ecg__000780F9DDC8_2022-03-10_14-25-19.txt'; %Enter the name of the file to be analysed and its extension (.txt)

delimiterIn = '\t'; %Specifies the delimiter (what divides two columns), in this case a tabulation

headerlinesIn = 3; %Number of Header lines to be ignored (comments with the name, characteristics, frequence...)

A = importdata(filename,delimiterIn,headerlinesIn); %Data is imported to a structure with the frame number and the acquired data
% It separates the headers from the data. In the structure outputted, 'data' contains the relevant data after the headers

samplingFreq = 400; % Frequence used for acquiring the signal

timePeriod = 1/samplingFreq; % Time between 2 acquisitions

Data = A.data; % Get the data from the structure

time = Data(:,1); % The first column of the the matrix contains the frame number

% Acquired information is stored sequentially: First the digital channel,
% then the other ports per order

ch1_Ag_electrodes = Data(:,3); % First acquired channel
ch2_Dry_Graphene_electrodes = Data(:,4); % Second acquired channel

% Sensor Power Supply in Volts
Vcc = 3;

% ADC Resolution in Bits
resolution = 16;

% ECG Sensor Gain
SensorGain = 1019;

% Time analysis window in seconds (s)
timeEnd = 8; % Indicate the last moment that you want to vizualise

timeAxis = 1:timeEnd*samplingFreq;

%% Transfer Function to get values in mV
% ECG(mV) = ((ADC/2^Resolution - 0,5)*Vcc ) / Gain * 1000
% Multiply by 1000 to convert V in mV
%%

% Convert RAW values in mV
ch1_Ag_electrodes_mV = ((ch1_Ag_electrodes ./ (2^resolution)) - 0.5) .* Vcc ./SensorGain .*1000;
ch2_Dry_Graphene_electrodes_mV = ((ch2_Dry_Graphene_electrodes ./ (2^resolution)) - 0.5) .* Vcc ./SensorGain .*1000;
%%

% Voltage axis
figure (1);
plot(timeAxis,ch1_Ag_electrodes_mV(timeAxis));
hold on;
plot(timeAxis, ch2_Dry_Graphene_electrodes_mV(timeAxis),'r');
%axis([0 length(timeAxis) -0.5 0.8])
hold on;
graphene = ch2_Dry_Graphene_electrodes_mV(timeAxis);

points = samplingFreq * timeEnd; % total number of points

xticks(samplingFreq:samplingFreq:points); % Vector of sampling number corresponding to each second from 1 to 8
xticklabels({'1', '2', '3', '4', '5', '6', '7', '8'});

xlabel('Time (s)');
ylabel('ECG (mV)');
title('Real acquisition');
legend('Ag/AgCl Normalized', 'Dry Electrodes Normalized');

%% Normalize values

% Get mean value, 'u'

u_Ag = mean(ch1_Ag_electrodes_mV(timeAxis));
u_Dry = mean(ch2_Dry_Graphene_electrodes_mV(timeAxis));

Ag_norm = ones(length(ch1_Ag_electrodes_mV(timeAxis)), 1);
Dry_norm = ones(length(ch2_Dry_Graphene_electrodes_mV(timeAxis)), 1);

MA_Ag = max(ch1_Ag_electrodes_mV(timeAxis));
MI_Ag = min(ch1_Ag_electrodes_mV(timeAxis));

MA_Dry = max(ch2_Dry_Graphene_electrodes_mV(timeAxis));
MI_Dry = min(ch2_Dry_Graphene_electrodes_mV(timeAxis));

for i = 1:length(ch1_Ag_electrodes_mV(timeAxis))
    Ag_norm(i) = (ch1_Ag_electrodes_mV(i) - u_Ag) / ( MA_Ag - MI_Ag);
    Dry_norm(i) = (ch2_Dry_Graphene_electrodes_mV(i) - u_Dry) / ( MA_Dry - MI_Dry);
end

figure(2);
plot(timeAxis,Ag_norm(timeAxis));
hold on;
plot(timeAxis, Dry_norm(timeAxis),'r');
%axis([0 length(timeAxis) -0.5 0.8])
hold on;

xlabel('Time (s)');
ylabel('ECG (mV)');
title('Normalized scale');