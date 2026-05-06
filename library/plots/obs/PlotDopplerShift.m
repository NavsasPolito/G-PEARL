function msg = PlotDopplerShift(directory, file, limit, epochDate, settings, varargin)
% This function generates the Doppler shift plot
%
% Written by Simone Zocca

if ~isempty(varargin)
    figureNum = varargin{1};
else
    figureNum = 900;
end

%--- Load the files
path = fullfile(directory, file);
m = load(path);

%--- Time axis
timeIdx = floor(limit(1)):floor(limit(2));
time = datetime(cell2mat([epochDate(timeIdx,1) epochDate(timeIdx,2)]));

%---Generate the plot
h = figure(figureNum);
set(h,'Name','DopplerShift');
clf;

for i = 1:length(m.obsSolutions)
    cString = char(m.obsSolutions(i).SV);

    hold on;
    if settings.(cString(1:3))
        %--- Find the right color
        svID = append(m.obsSolutions(i).SV," ",m.obsSolutions(i).band);
        RGBcolor = PRNColors(svID);

        plot(time, m.obsSolutions(i).Doppler(timeIdx),'Color',RGBcolor,'DisplayName',svID,'LineWidth',1.2);
    end
end

hold off;
%--- Specs of the plot
ylabel('[Hz]');
xlabel('Time');
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
Pix_SS = get(0,'screensize');
if figureNum == 140
    h.OuterPosition = [Pix_SS(3)/2 Pix_SS(4)/2 Pix_SS(3)/2 Pix_SS(4)/2];
else
    h.OuterPosition = [Pix_SS(3)/2 Pix_SS(4)/2 Pix_SS(3)/4 Pix_SS(4)/2];
end

%--- Title and message
title("RINEX Obs - Doppler Shifts");
msg = "RINEX Obs - Doppler shifts plot generated";