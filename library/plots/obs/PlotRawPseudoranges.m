function msg = PlotRawPseudoranges(directory, file, limit, epochDate, settings, varargin)
% This function generates the raw pseudoranges plot
%
% Written by Simone Zocca

if ~isempty(varargin)
    figureNun = varargin{1};
else
    figureNun = 900;
end

%--- Load the files
path = fullfile(directory,file);
m = load(path);

%--- Time Axis
timeIdx = floor(limit(1)):floor(limit(2));
time = datetime(cell2mat([epochDate(timeIdx,1) epochDate(timeIdx,2)]));

%--- Generate the plot
h = figure(figureNun);
set(h,'Name','RawPseudoranges');
clf;

for i = 1:length(m.obsSolutions)
    cString = char(m.obsSolutions(i).SV);

    hold on;
    if settings.(cString(1:3))
        %--- Find the right color
        svID = append(m.obsSolutions(i).SV," ",m.obsSolutions(i).band);
        RGBcolor = PRNColors(svID);

        plot(time, m.obsSolutions(i).rawP(timeIdx),'Color',RGBcolor,'DisplayName',svID,'LineWidth',1.2);
    end
end

hold off;
%--- Specs of the plot
ylabel('[m]');
xlabel('Time');
axis tight;
grid on;
ticksVector = getTicks(limit);
xticks(time(ticksVector));
xticklabels(string(timeofday(time(ticksVector))));
subtitle(strcat("Start Date: ",epochDate{1,1},"  |  End Date: ",epochDate{ticksVector(6),1}))

%--- Add listener for datatips
datacursormode on;
dcm = datacursormode(h);
set(dcm,'UpdateFcn',@customDataTip);

hLeg = legend('Location','eastoutside','NumColumns',2,'FontSize',8);
hLeg.ItemHitFcn = @action1;

Pix_SS = get(0,'screensize');
h.OuterPosition = [Pix_SS(3)/2 Pix_SS(4)/2 Pix_SS(3)/2 Pix_SS(4)/2];

title("RINEX Obs - Raw Pseudoranges");
msg = "RINEX Obs - raw pseudoranges plot generated";