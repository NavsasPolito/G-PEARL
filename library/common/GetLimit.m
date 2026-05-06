function [navLimit, obsLimit] = GetLimit(directory,file1,file2)
% This function returns the number of Epochs

%--- Return obs limits
try
    path = fullfile(directory,file1);
    m = load(path);

    obsLimit = [1 length(m.obsSolutions(1).rawP)];
catch
    obsLimit = [];
    %warning('Error in the extraction of observables limits')
end

%--- Return nav limits
try
    path2 = fullfile(directory,file2);
    m2 = load(path2);

    navLimit = [1 length(m2.navSolutions.latitude)];
catch
    navLimit = [];
end