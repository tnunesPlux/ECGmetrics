filename = ['PE1_SNR.txt']; %Enter the name of the file to be analysed and its extension (.txt)

delimiterIn = '\t'; %Specifies the delimiter (what divides two columns), in this case a tabulation

headerlinesIn = 1; %Number of Header lines to be ignored (comments with the name, characteristics, frequence...)

A = importdata(filename,delimiterIn,headerlinesIn); %Data is imported to a structure with the frame number and the acquired data
% It separates the headers from the data. In the structure outputted, 'data' contains the relevant data after the headers

Data = A.data; % Get the data from the structure

time = Data(:,1); % The first column of the the matrix contains the frame number

% Acquired information is stored sequentially: First the digital channel,
% then the other ports per order

ch1 = Data(:,2);    % First acquired channel
ch2 = Data(:,3);    % Second acquired channel
math1 = Data(:,4);  % Math channel, 2nd minus 1st channel

% Voltage axis
subplot(2, 1, 1);
plot(time,ch1);
hold on;
plot(time, ch2);
axis([-0.03 0.03 -0.15 0.15]);

plot(time, math1);
legend('CH1', 'CH2', 'Math1');
title('Signals measured at Input and Output of the Electrode');
ylabel('Amplitude (V)');
xlabel('Time (s)');

subplot(2, 1, 2);
plot(time, smoothdata(math1));
axis([-0.03 0.03 -50e-4 60e-4]);
ylabel('Amplitude (mV)');
xlabel('Time (s)');
title('Math1 (Close up)');