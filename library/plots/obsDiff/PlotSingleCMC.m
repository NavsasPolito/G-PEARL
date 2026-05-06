function [msg] = PlotSingleCMC(directory, file, limit, epochDate, settings, varargin)
% This function generates the single frequency CMC plot 
%
% Written by Simone Zocca
 
if ~isempty(varargin)
    figureNum = varargin{1};
else
    figureNum = 900;
end

%--- Load files
path = fullfile(directory, file);
m = load(path);

%--- Time axis
timeIdx = floor(limit(1)):floor(limit(2));
time = datetime(cell2mat([epochDate(timeIdx,1) epochDate(timeIdx,2)]));

%--- Initialize variables
offset = nan(length(m.obsSolutions), numel(timeIdx));
nSat  = zeros(1, numel(timeIdx));

%--- Count number of Svs in each epoch to see if there are
% "Holes" in the RAW files
for i = 1:length(m.obsSolutions)
    nSat = nSat + ~isnan(m.obsSolutions(i).rawP);
end

%--- Generate figure
h = figure(figureNum);
set(h,'Name','SingleCMC');

%--- Find indexes at which data starts and ends, then calculate offsets for
% each interval
for i = 1:length(m.obsSolutions)
    coeff = physconst('lightspeed') / m.obsSolutions(i).freq;
    cmc = m.obsSolutions(i).rawP(timeIdx) - coeff * m.obsSolutions(i).CarrierPhase(timeIdx);

    %--- Find start and end indexes of all segments
    sIdx = find(diff(isnan(cmc)) == -1) + 1;
    eIdx = find(diff(isnan(cmc)) == 1);

    sIdx = sIdx(~ismember(sIdx, find(nSat == 0) + 1));
    eIdx = eIdx(~ismember(eIdx, find(nSat == 0) - 1));

    if isempty(sIdx) && isempty(eIdx)
        sIdx = 1;
        eIdx = timeIdx(end);
    elseif numel(sIdx) < numel(eIdx)
        sIdx = [1 sIdx];
    elseif numel(eIdx) < numel(sIdx)
        eIdx = [eIdx timeIdx(end)];
    end

    %--- Find initial value of each segment
    for j = 1:numel(sIdx)
        %--- First approach, take the mean
        %offset(sIdx(j):eIdx(j)) = mean(cmc(sIdx(j):eIdx(j)));
        %--- Second approach, take first value
        offset(i, sIdx(j):eIdx(j)) = cmc(sIdx(j));
    end

    cString = char(m.obsSolutions(i).SV);

    hold on;
    if settings.(cString(1:3))
        %--- Find the right color
        svID = append(m.obsSolutions(i).SV," ",m.obsSolutions(i).band);
        RGBcolor = PRNColors(svID);

        plot(time, cmc(timeIdx) - offset(i, timeIdx),'-','Color',RGBcolor,'MarkerSize', 2,'DisplayName',svID,'LineWidth',1.1);
        %--- Plot without offset for testing
        %plot(time, cmc(timeIdx),'-','Color',RGBcolor,'MarkerSize', 2,'DisplayName',svID,'LineWidth',1.1);
    end
end

hold off;
%--- Specs of the plot
xlabel('Time');
ylabel('Shifted 1F CMC [m]');
axis tight;
grid on;
ticksVector = getTicks(limit);
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
title("RINEX Obs - Shifted 1F CMC");
Pix_SS = get(0,'screensize');
h.OuterPosition = [Pix_SS(3)/2 Pix_SS(4)/2 Pix_SS(3)/2 Pix_SS(4)/2];

%--- Message
msg = "Shifted 1F CMC plot generated";