function getSegments(Ag_electrodes, Dry_Graphene_electrodes)
    % By plotting the two signals, we can evaluate the regions where the
    % signals present significant differences that may have been induced by
    % some specific noise to one setup only

    figure (1);
    plot(Ag_electrodes);
    hold on;
    plot(Dry_Graphene_electrodes,'r');
    
    %% Select data to be segmented
    
    pause;
    
    % While paused, use the brush functin to select the segments of the
    % signal that you want to analyse. After selecting the segment,
    % right-click on it and chose 'Export brushed data' give it a
    % predefined name used in the following section inside 'Indexes' and,
    % if needed, add more variables to it. Once all the segments have been
    % exported, press the console and click enter to continue the script
    
    %% Uncomment after getting values
    % Add variables as needed
%     Indexes = {brushedData_1, brushedData_2, brushedData_3, brushedData_4,brushedData_5, brushedData_6};
%     
%     limits = zeros(length(Indexes), 2);
%     
%     % Get only the indexes
%     for i = 1:length(Indexes)
%         Indexes{i} = Indexes{i}(:,1);
%         limits(i,:) = [Indexes{i}(1), Indexes{i}(end)];  % First and last element of first segment  
%     end
end