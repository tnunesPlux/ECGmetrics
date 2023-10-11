function [Ag_norm, Dry_norm] = NormSegment(ch1_Ag_electrodes, ch2_Dry_Graphene_electrodes, timeAxis)
    % Get mean value, 'u'
    
    u_Ag = mean(ch1_Ag_electrodes(timeAxis));
    u_Dry = mean(ch2_Dry_Graphene_electrodes(timeAxis));
    
    Ag_norm = ones(length(ch1_Ag_electrodes(timeAxis)), 1);
    Dry_norm = ones(length(ch2_Dry_Graphene_electrodes(timeAxis)), 1);
    
    MAX_Ag = max(ch1_Ag_electrodes(timeAxis));
    MIN_Ag = min(ch1_Ag_electrodes(timeAxis));
    
    MAX_Dry = max(ch2_Dry_Graphene_electrodes(timeAxis));
    MIN_Dry = min(ch2_Dry_Graphene_electrodes(timeAxis));
    
    for i = 1:length(ch1_Ag_electrodes(timeAxis))
        Ag_norm(i) = (ch1_Ag_electrodes(i) - u_Ag) / ( MAX_Ag - MIN_Ag);
        Dry_norm(i) = (ch2_Dry_Graphene_electrodes(i) - u_Dry) / ( MAX_Dry - MIN_Dry);
    end
end