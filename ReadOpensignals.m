%% Opensignals(r) .txt file reader
% 
%
%
%
%
%
%%
%close all;

%Enter the name of the file to be analysed and its extension (.txt) and the
%acquisition freuqency, and the starting point for visualization

PE1PE2 = {'ecg_dry_pe1_pe2_886B0FABF70B_2021-12-01_20-45-27.txt', 1000, 170000, 'PE1 and PE2'}; 

PE5PE6 = {'ecg_dry_pe5_pe6_886B0FABF70B_2021-12-01_20-52-37.txt', 1000, 260000, 'PE5 and PE6'};

PE3PE4 = {'ecg_wet_pe3_pe4_886B0FABF70B_2021-12-01_21-03-12.txt', 1000, 103000,'PE3 and PE4'};

PE7PE8 = {'ecg_wet_PE7_PE8_886B0FABF70B_2021-12-01_21-14-29.txt', 1000, 120000, 'PE7 and PE8'};

PE15PE16 = {'ecg__000780F9DDC8_2022-05-04_17-49-43.txt', 1000, 31000,'PE15 and PE16'};

Cheststrap = {'ecg_Cardioban_ChestStrap_886B0FABF70B_2021-12-01_20-38-37.txt', 1000, 40000, 'Chest band'};

Gelled = {'ecg__000780F9DDC8_2022-03-10_14-25-19.txt', 400, 59000, 'Gelled Ag/AgCl'}; 

[filename, samplingFreq, startPoint, name] = getNameFreq(Gelled);

delimiterIn = '\t'; %Specifies the delimiter (what divides two columns), in this case a tabulation

headerlinesIn = 3; %Number of Header lines to be ignored (comments with the name, characteristics, frequence...)

A = importdata(filename,delimiterIn,headerlinesIn); %Data is imported to a structure with the frame number and the acquired data
% It separates the headers from the data. In the structure outputted, 'data' contains the relevant data after the headers

Data = A.data; % Get the data from the structure

CH1 = Data(:,4);

%% Conversion from RAW values to mV

% ECG Sensor Gain
SensorGain = 1019;

% Biosignalsplux power supply in V
Vcc = 3;

% Biosignalsplux ADC resolution
resolution = 16;

% Transfer function from Raw to mV
CH1_mV = ((CH1 ./ (2^resolution)) - 0.5) .* Vcc ./SensorGain .*1000;

figure(3);
% First plot to select start and end point
plot(1:length(CH1_mV), CH1_mV);

points = 8*samplingFreq; % Seconds * Acquisition Frequency

dataSet = CH1_mV(startPoint : startPoint + points - 1);

plot(1:points, dataSet);

axis([1 points -0.6 0.8]);

xticks(samplingFreq:samplingFreq:points); % Vector of sampling number corresponding to each second from 1 to 8
xticklabels({'1', '2', '3', '4', '5', '6', '7', '8'});

xlabel('Time (s)');
ylabel('ECG (mV)');
title(sprintf('ECG acquired with %s', name));


%%%%%%%%%%%%%%%%%%% Functions %%%%%%%%%%%%%%%%%%%


function [filename, freq, star, name] = getNameFreq(struct)
    filename = struct{1};
    freq = struct{2};
    star = struct{3};
    name = struct{4};
end
