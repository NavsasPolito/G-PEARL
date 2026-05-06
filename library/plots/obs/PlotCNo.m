function msg = PlotCNo(directory, file, limit, epochDate, settings, varargin)
% This function generates the C/N0 plot
%
% Written by Simone Zocca

if ~isempty(varargin)
    figureNum = varargin{1};
else
    figureNum = 900;
end

%--- Load files
path = fullfile(directory,file);
m = load(path);

%--- Time axis
timeIdx = floor(limit(1)):floor(limit(2));
time = datetime(cell2mat([epochDate(timeIdx,1) epochDate(timeIdx,2)]));

%--- Generate the plot
h = figure(figureNum);
set(h,'Name','C/N0');
clf;

for i = 1:length(m.obsSolutions)
    cString = char(m.obsSolutions(i).SV);

    hold on;
    if settings.(cString(1:3))
        %--- Calculate color
        svID = append(m.obsSolutions(i).SV," ",m.obsSolutions(i).band);
        RGBcolor = PRNColors(svID);

        plot(time, m.obsSolutions(i).cn0(timeIdx),'Color',RGBcolor,'DisplayName',svID,'LineWidth',1.1);
    end
end

hold off;
%--- Specs of the plot
ylabel('C/N0 [dB-Hz]');
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
h.OuterPosition = [Pix_SS(3)/2 Pix_SS(4)/2 Pix_SS(3)/2 Pix_SS(4)/2]; 

%--- Message
title("RINEX Obs - C/N0");
msg = "RINEX Obs - C/N0 plot generated";