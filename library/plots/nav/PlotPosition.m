function [msg01] = PlotPosition(directory, file, limit, epochDate, refFrame, varargin)
% This function generates the position plot
%
% Written by Simone Zocca

if ~isempty(varargin)
    figureNum = varargin{1};
    try
        file2 = varargin{3};
        path2 = fullfile(directory, file2);
        m2 = load(path2);
    catch
        %warning("Failed to upload reference trajectory");
    end   
else
    figureNum = 900;
end

%--- Load NAV data
path = fullfile(directory, file);
m = load(path);

%--- Time axis
timeIdx = floor(limit(1)):floor(limit(2));
time = datetime(cell2mat([epochDate(timeIdx,1) epochDate(timeIdx,2)]));

%--- Generate plot
h = figure(figureNum);
set(h,'Name','Position');
clf;

subplot(3, 1, 1)
if refFrame == 1
    plot(time, m.navSolutions.X_eci(timeIdx),'LineWidth',1.1,'DisplayName','NAV');
else
    plot(time, m.navSolutions.X(timeIdx),'LineWidth',1.1,'DisplayName','NAV');
end

if exist('m2','var') && ~isempty(m2)
    hold on;
    if refFrame == 1
        plot(time, m2.navSolutions.X_eci(timeIdx),'k--','LineWidth',1.1,'DisplayName','REF');
    else
        plot(time, m2.navSolutions.X(timeIdx),'k--','LineWidth',1.1,'DisplayName','REF');
    end
end

title('X');
ylabel('[m]');
ylim('tight');
xlim([time(1) time(end)]);
grid on;
ticksVector = getTicks(limit);
xticks(time(ticksVector));
xticklabels(string(timeofday(time(ticksVector))));
xtickangle(0);


subplot(3, 1, 2)
if refFrame == 1
    plot(time, m.navSolutions.Y_eci(timeIdx),'LineWidth',1.1,'DisplayName','NAV');
else
    plot(time, m.navSolutions.Y(timeIdx),'LineWidth',1.1,'DisplayName','NAV');
end

if exist('m2','var') && ~isempty(m2)
    hold on;
    if refFrame == 1
        plot(time, m2.navSolutions.Y_eci(timeIdx),'k--','LineWidth',1.1,'DisplayName','REF');
    else
        plot(time, m2.navSolutions.Y(timeIdx),'k--','LineWidth',1.1,'DisplayName','REF');
    end
end

title('Y');
ylabel('[m]');
ylim('tight');
xlim([time(1) time(end)]);
grid on;
xticks(time(ticksVector));
xticklabels(string(timeofday(time(ticksVector))));
xtickangle(0);

subplot(3, 1, 3)
if refFrame == 1
    plot(time, m.navSolutions.Z_eci(timeIdx),'LineWidth',1.1,'DisplayName','NAV');
else
    plot(time, m.navSolutions.Z(timeIdx),'LineWidth',1.1,'DisplayName','NAV');
end

if exist('m2','var') && ~isempty(m2)
    hold on;
    if refFrame == 1
        plot(time, m2.navSolutions.Z_eci(timeIdx),'k--','LineWidth',1.1,'DisplayName','REF');
    else
        plot(time, m2.navSolutions.Z(timeIdx),'k--','LineWidth',1.1,'DisplayName','REF');
    end
end

title('Z');
ylabel('[m]');
xlabel('Time');
ylim('tight');
xlim([time(1) time(end)]);
grid on;
xticks(time(ticksVector));
xticklabels(string(timeofday(time(ticksVector))));
xtickangle(0);

%--- Add listener for datatips
datacursormode on;
dcm = datacursormode(h);
set(dcm,'UpdateFcn',@customDataTip);

%--- Legend
hLeg = legend('Location','Best');
%hLeg.ItemHitFcn = @action1;

%--- Plot location
Pix_SS = get(0,'screensize');
h.OuterPosition = [Pix_SS(3)/2 Pix_SS(2) Pix_SS(3)/2 Pix_SS(4)/2];


%--- Title
if refFrame == 1
    sgt = sgtitle({['{\bf' 'NMEA - Position (ECI)' '}'], strcat("Start Date: ",epochDate{1,1},"  |  End Date: ",epochDate{ticksVector(6),1})});
    msg01 = "NMEA - Position plot (ECI) generated";
else
    sgt = sgtitle({['{\bf' 'NMEA - Position (ECEF)' '}'], strcat("Start Date: ",epochDate{1,1},"  |  End Date: ",epochDate{ticksVector(6),1})});
    msg01 = "NMEA - Position plot (ECEF) generated";
end
sgt.FontSize = 10;