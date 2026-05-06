function [msg01,msg02,msg03,statTable] = PlotDiffDiff(directory, file, limit, epochDate, settings, varargin)

if ~isempty(varargin)
    figureNum = varargin{1};
else
    figureNum = 900;
end

%--- Load the files
path1 = fullfile(directory, file);
m = load(path1);

%--- Time axis
timeIdx = floor(limit(1)):floor(limit(2));
time = datetime(cell2mat([epochDate(timeIdx,1) epochDate(timeIdx,2)]));

%--- Put measurements in a matrix for simplicity of access
obsMeas = vertcat(m.obsSolutions.rawP);
phaseMeas = vertcat(m.obsSolutions.CarrierPhase);

%% Generate pseudorange plot
h = figure(figureNum);
set(h,'Name','CodeThirdDiff');
clf;

%--- Initialize
codeMu    = zeros(length(m.obsSolutions),1);
codeSigma = zeros(length(m.obsSolutions),1);

for i = 1:size(obsMeas,1)
    %--- Finite difference coefficient (3nd derivative 4th accuracy order)
    [obsDiff, n_c] = centralFiniteDiff(obsMeas(i,timeIdx), 3, 4);
    n_c = floor(n_c / 2);

    cString = char(m.obsSolutions(i).SV);

    hold on;
    if settings.(cString(1:3))
        %--- Find the right color
        svID = append(m.obsSolutions(i).SV," ",m.obsSolutions(i).band);
        RGBcolor = PRNColors(svID);

        plot(time(n_c+1:end-n_c), obsDiff,'Color',RGBcolor,'DisplayName',svID,'LineWidth',1.1);
    end

    %--- Compute mean and std of pseudorange nth derivative
    codeMu(i) = mean(obsDiff,"omitnan");
    codeSigma(i) = std(obsDiff,"omitnan");
end

hold off;
%--- Specs of the plot
ylabel('[m]');
xlabel('Time');
axis tight;
grid on;
ticksVector = getTicks([n_c+1 limit(2)-n_c]);
xticks(time(ticksVector));
xticklabels(string(timeofday(time(ticksVector))));
subtitle(strcat("Start Date: ",epochDate{1,1},"  |  End Date: ",epochDate{ticksVector(6),1}));

%--- Add listener for datatips
datacursormode on;
dcm = datacursormode(h);
set(dcm,'UpdateFcn',@customDataTip);

%--- Legend
hLeg = legend('Location','eastoutside','NumColumns',2,'FontSize',8);
hLeg.ItemHitFcn = @action1;

%--- Title and plot location
Pix_SS = get(0,'screensize');
title('RINEX Obs - Pseudorange third derivative');
h.OuterPosition = [Pix_SS(3)/2 Pix_SS(4)/2 Pix_SS(3)/2 Pix_SS(4)/2];

%--- Message
msg01 = "Pseudorange third derivative plot generated";

%% Generate carrier phase plot
h = figure(figureNum + 1);
set(h,'Name','PhaseThirdDiff');
clf;

%--- Initialize
phaseMu    = zeros(length(m.obsSolutions),1);
phaseSigma = zeros(length(m.obsSolutions),1);

for i = 1:size(phaseMeas,1)
    %--- Finite difference coefficient (3nd derivative 4th accuracy order)
    [obsDiff, n_c] = centralFiniteDiff(phaseMeas(i,timeIdx), 3, 4);
    n_c = floor(n_c / 2);

    cString = char(m.obsSolutions(i).SV);

    hold on;
    if settings.(cString(1:3))
        %--- Find the right color
        svID = append(m.obsSolutions(i).SV," ",m.obsSolutions(i).band);
        RGBcolor = PRNColors(svID);

        plot(time(n_c+1:end-n_c),obsDiff,'Color',RGBcolor,'DisplayName',svID,'LineWidth',1.1);
    end

    %--- Compute mean and std of pseudorange nth derivative
    phaseMu(i) = mean(obsDiff,"omitnan");
    phaseSigma(i) = std(obsDiff,"omitnan");
end

hold off;
%--- Specs of the plot
ylabel('[m]');
xlabel('Time');
axis tight;
grid on;
ticksVector = getTicks([n_c+1 limit(2)-n_c]);
xticks(time(ticksVector));
xticklabels(string(timeofday(time(ticksVector))));
subtitle(strcat("Start Date: ",epochDate{1,1},"  |  End Date: ",epochDate{ticksVector(6),1}));

%--- Add listener for datatips
datacursormode on;
dcm = datacursormode(h);
set(dcm,'UpdateFcn',@customDataTip);

%--- Legend
hLeg = legend('Location','eastoutside','NumColumns',2,'FontSize',8);
hLeg.ItemHitFcn = @action1;

%--- Title and plot location
Pix_SS = get(0,'screensize');
title("RINEX Obs - Carrier phase third derivative");
h.OuterPosition = [Pix_SS(3)/2 1 Pix_SS(3)/2 Pix_SS(4)/2];

%--- Message
msg02 = "Carrier phase third derivative plot generated";

%% Create table of statistics
statTable = table(cellstr(vertcat(m.obsSolutions.channel)),cellstr(string(vertcat(m.obsSolutions.PRN))), num2cell(codeMu), num2cell(codeSigma), num2cell(phaseMu), num2cell(phaseSigma),'VariableNames',{'Channel','PRN','Code Mean','Code St.dev.','Phase mean','Phase St.dev.'});

msg03 = "Statistics table generated";