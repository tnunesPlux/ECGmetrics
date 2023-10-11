Signal = "carbon";

f_RMSE = append("RMSE_", string(Signal), ".txt");
f_CS = append("CS_", string(Signal), ".txt");

CS_values = importdata(f_CS);

mean(CS_values);
std(CS_values);

fprintf('\nResults of Signal %s\n', Signal);

fprintf('Cosine Similarity of signal is: \n %f+-%f\n',  mean(CS_values), std(CS_values));
fprintf('Sample size: %d\n', length(CS_values));

fprintf('\n');

RMSE_values = importdata(f_RMSE);

mean(RMSE_values);
std(RMSE_values);

fprintf('RMSE of signal is: \n %f+-%f\n',  mean(RMSE_values), std(RMSE_values));
fprintf('Sample size: %d\n', length(RMSE_values));