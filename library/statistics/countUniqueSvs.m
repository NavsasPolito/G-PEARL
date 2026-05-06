function [GPS, GLO, GAL, BDS] = countUniqueSvs(obsSolutions, settings)

%--- Initialize total visibility
GPS = zeros(1,length(obsSolutions(1).cn0));
GLO = zeros(1,length(obsSolutions(1).cn0));
GAL = zeros(1,length(obsSolutions(1).cn0));
BDS = zeros(1,length(obsSolutions(1).cn0));

%--- Save local variables to avoid accessing the struct too many times
PRNs = [obsSolutions.PRN];
channels = {obsSolutions.channel};

%% Search where GPS PRNs are in obsSolutions
for j = 1:32
    temp = intersect(find(PRNs == j), find(contains(channels,"L1")));
    if isscalar(temp)
        vis1 = obsSolutions(temp).cn0 > settings.threshold;
    else
        vis1 = false(1,length(obsSolutions(1).cn0));
    end

    temp = intersect(find(PRNs == j), find(contains(channels,"L2")));
    if isscalar(temp)
        vis2 = obsSolutions(temp).cn0 > settings.threshold;
    else
        vis2 = false(1,length(obsSolutions(1).cn0));
    end

    temp = intersect(find(PRNs == j), find(contains(channels,"L5")));
    if isscalar(temp)
        vis3 = obsSolutions(temp).cn0 > settings.threshold;
    else
        vis3 = false(1,length(obsSolutions(1).cn0));
    end

    %--- Sum to total
    GPS = GPS + double(vis1 | vis2 | vis3);
end


%% Search where GLO PRNs are in obsSolutions
for j = 1:60
    temp = intersect(find(PRNs == j), find(contains(channels,["G1", "G4"])));
    if isscalar(temp)
        vis1 = obsSolutions(temp).cn0 > settings.threshold;
    else
        vis1 = false(1,length(obsSolutions(1).cn0));
    end

    temp = intersect(find(PRNs == j), find(contains(channels,["G2", "G6"])));
    if isscalar(temp)
        vis2 = obsSolutions(temp).cn0 > settings.threshold;
    else
        vis2 = false(1,length(obsSolutions(1).cn0));
    end

    temp = intersect(find(PRNs == j), find(contains(channels,"G3")));
    if isscalar(temp)
        vis3 = obsSolutions(temp).cn0 > settings.threshold;
    else
        vis3 = false(1,length(obsSolutions(1).cn0));
    end

    %--- Sum to total
    GLO = GLO + double(vis1 | vis2 | vis3);
end

%% Search where GAL PRNs are in obsSolutions
for j = 1:36
    temp = intersect(find(PRNs == j), find(contains(channels,"E1")));
    if isscalar(temp)
        vis1 = obsSolutions(temp).cn0 > settings.threshold;
    else
        vis1 = false(1,length(obsSolutions(1).cn0));
    end

    temp = intersect(find(PRNs == j), find(contains(channels,["E5", "E7", "E8"])));
    if isscalar(temp)
        vis2 = obsSolutions(temp).cn0 > settings.threshold;
    else
        vis2 = false(1,length(obsSolutions(1).cn0));
    end

    temp = intersect(find(PRNs == j), find(contains(channels,"E6")));
    if isscalar(temp)
        vis3 = obsSolutions(temp).cn0 > settings.threshold;
    else
        vis3 = false(1,length(obsSolutions(1).cn0));
    end

    %--- Sum to total
    GAL = GAL + double(vis1 | vis2 | vis3);
end

%% Search where BDS PRNs are in obsSolutions
for j = 1:60
    temp = intersect(find(PRNs == j), find(contains(channels,["B1", "B2"])));
    if isscalar(temp)
        vis1 = obsSolutions(temp).cn0 > settings.threshold;
    else
        vis1 = false(1,length(obsSolutions(1).cn0));
    end

    temp = intersect(find(PRNs == j), find(contains(channels,["B5", "B7", "B8"])));
    if isscalar(temp)
        vis2 = obsSolutions(temp).cn0 > settings.threshold;
    else
        vis2 = false(1,length(obsSolutions(1).cn0));
    end

    temp = intersect(find(PRNs == j), find(contains(channels,"B6")));
    if isscalar(temp)
        vis3 = obsSolutions(temp).cn0 > settings.threshold;
    else
        vis3 = false(1,length(obsSolutions(1).cn0));
    end

    %--- Sum to total
    BDS = BDS + double(vis1 | vis2 | vis3);
end