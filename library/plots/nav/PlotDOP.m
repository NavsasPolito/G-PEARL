function [msg01] = PlotDOP(directory, file, limit, epochDate, varargin)
% This function generates the DOP plot
%
% Written by Simone Zocca

if ~isempty(varargin)
    figureNum = varargin{1};

    try
        file2 = varargin{2};
        path2 = fullfile(directory, file2);
        m2 = load(path2);
    catch
        warning("Failed to upload reference trajectory");
    end
else
    figureNum = 900;
end

%--- Load files
path = fullfile(directory, file);
m = load(path);

%--- Time axis
timeIdx = floor(limit(1)):floor(limit(2));
time = datetime(cell2mat([epochDate(timeIdx,1) epochDate(timeIdx,2)]));

% --- Generate plot
h = figure(figureNum);
set(h,'Name','DOPs');
clf;

% 1) GDOP 2) PDOP 3) HDOP 4) VDOP 5) TDOP
subplot(2,1,1)
plot(time, m.navSolutions.DOP(1,timeIdx),'k','LineWidth',1.5,'DisplayName','NAV GDOP');
hold on;
plot(time, m.navSolutions.DOP(2,timeIdx),'b','LineWidth',1.5,'DisplayName','NAV PDOP');
plot(time, m.navSolutions.DOP(3,timeIdx),'g','LineWidth',1.5,'DisplayName','NAV HDOP');
plot(time, m.navSolutions.DOP(4,timeIdx),'c','LineWidth',1.5,'DisplayName','NAV VDOP');
plot(time, m.navSolutions.DOP(5,timeIdx),'r','LineWidth',1.5,'DisplayName','NAV TDOP');

if exist('m2','var') && ~isempty(m2)
    plot(time, m2.navSolutions.DOP(1,timeIdx),'k:','LineWidth',1.5,'DisplayName','REF GDOP');
    plot(time, m2.navSolutions.DOP(2,timeIdx),'b:','LineWidth',1.5,'DisplayName','REF PDOP');
    plot(time, m2.navSolutions.DOP(3,timeIdx),'g:','LineWidth',1.5,'DisplayName','REF PDOP');
    plot(time, m2.navSolutions.DOP(4,timeIdx),'c:','LineWidth',1.5,'DisplayName','REF PDOP');
    plot(time, m2.navSolutions.DOP(5,timeIdx),'r:','LineWidth',1.5,'DisplayName','REF TDOP');
end

%--- Specs
title('NMEA - Dilution of Precision metrics');
ylabel('DOPs');
xlabel('Time');
ylim([0 max(m.navSolutions.DOP,[],'all')]);
xlim([time(1) time(end)]);
grid on;
ticksVector = getTicks(limit);
xticks(time(ticksVector));
xticklabels(string(timeofday(time(ticksVector))));
subtitle(strcat("Start Date: ",epochDate{1,1},"  |  End Date: ",epochDate{ticksVector(6),1}));

%--- Legend
hLeg = legend('Location','best');
hLeg.ItemHitFcn = @action1;


subplot(2,1,2)
plot(time, m.navSolutions.nSat(timeIdx),'k','LineWidth',1.5,'DisplayName',"#Sat");

%--- Specs
title('NMEA - Number of used Satellites');
ylabel('# sat');
xlabel('Time');
ylim([0 max(m.navSolutions.nSat)]);
xlim([time(1) time(end)]);
grid on;
xticks(time(ticksVector));
xticklabels(string(timeofday(time(ticksVector))));

%--- Add listener for datatips
datacursormode on;
dcm = datacursormode(h);
set(dcm,'UpdateFcn',@customDataTip);

%--- Plot location
Pix_SS = get(0,'screensize');
h.OuterPosition = [Pix_SS(3)/2 Pix_SS(4)/4 Pix_SS(3)/2 3*Pix_SS(4)/4];

msg01 = "NMEA - DOPs plot generated";