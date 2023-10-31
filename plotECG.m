%% Tiago Nunes, 2023
% Plot overlapping ECG segments from a .txt file 

close all;

filename = ".\ECG_segments.txt";

segments = readmatrix(filename);

for i = 1:size(segments, 1)
    figure(1);
    plot(segments(i,:), Color= [0 0.4470 0.7410 0.2]);
    hold on;
end