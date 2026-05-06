function [msg01, msg02, msg03] = PlotAvailability(directory, file1, file2, limit, epochDate, settings, varargin)
% This function calculates and plot visibility metrics
%
% Written by Simone Zocca

%--- Load obs
path1 = fullfile(directory,file1);
m1 = load(path1);

%--- Load nav
useNavFlag = 0;
if ~isempty(file2) && ~isempty(directory)
    path2 = fullfile(directory,file2);
    m2 = load(path2);

    if exist('m2','var') && ~isempty(m2.navSolutions) && length(m2.navSolutions.UTCtime) == length(epochDate)
        useNavFlag = 1;
    end
end

figureNum = 110;
figureName = "RINEX Obs";

%% Calcuate signal availability for mission data
L1mission = zeros(1,length(m1.obsSolutions(1).cn0));
L1idx = zeros(1,60);
L2mission = zeros(1,length(m1.obsSolutions(1).cn0));
L2idx = zeros(1,60);
L5mission = zeros(1,length(m1.obsSolutions(1).cn0));
L5idx = zeros(1,60);

G1mission = zeros(1,length(m1.obsSolutions(1).cn0));
G1idx = zeros(1,60);
G2mission = zeros(1,length(m1.obsSolutions(1).cn0));
G2idx = zeros(1,60);
G3mission = zeros(1,length(m1.obsSolutions(1).cn0));
G3idx = zeros(1,60);

E1mission = zeros(1,length(m1.obsSolutions(1).cn0));
E1idx = zeros(1,60);
E5mission = zeros(1,length(m1.obsSolutions(1).cn0));
E5idx = zeros(1,60);
E6mission = zeros(1,length(m1.obsSolutions(1).cn0));
E6idx = zeros(1,60);

B1mission = zeros(1,length(m1.obsSolutions(1).cn0));
B1idx = zeros(1,60);
B2mission = zeros(1,length(m1.obsSolutions(1).cn0));
B2idx = zeros(1,60);
B3mission = zeros(1,length(m1.obsSolutions(1).cn0));
B3idx = zeros(1,60);

for j = 1:length(m1.obsSolutions)
    channel = char(m1.obsSolutions(j).channel);
    switch channel(1:2)
        case 'L1' % L1 bandf
            if L1idx(m1.obsSolutions(j).PRN) == 0
                L1mission = L1mission + double(m1.obsSolutions(j).cn0 > settings.threshold);
                L1idx(m1.obsSolutions(j).PRN) = 1;
            end
        case 'L2' % L2 band
            if L2idx(m1.obsSolutions(j).PRN) == 0
                L2mission = L2mission + double(m1.obsSolutions(j).cn0 > settings.threshold);    
                L2idx(m1.obsSolutions(j).PRN) = 1;
            end
        case 'L5' % L5 band
            if L5idx(m1.obsSolutions(j).PRN) == 0
                L5mission = L5mission + double(m1.obsSolutions(j).cn0 > settings.threshold);    
                L5idx(m1.obsSolutions(j).PRN) = 1;
            end
        case {'G1', 'G4'} % G1 band
            if G1idx(m1.obsSolutions(j).PRN) == 0
                G1mission = G1mission + double(m1.obsSolutions(j).cn0 > settings.threshold);
                G1idx(m1.obsSolutions(j).PRN) = 1;
            end      
        case {'G2', 'G6'} % G2 band
            if G2idx(m1.obsSolutions(j).PRN) == 0
                G2mission = G2mission + double(m1.obsSolutions(j).cn0 > settings.threshold);
                G2idx(m1.obsSolutions(j).PRN) = 1;
            end
        case 'G3' % G3 band
            if G3idx(m1.obsSolutions(j).PRN) == 0
                G3mission = G3mission + double(m1.obsSolutions(j).cn0 > settings.threshold);
                G3idx(m1.obsSolutions(j).PRN) = 1;
            end
        case 'E1' % E1 band
            if E1idx(m1.obsSolutions(j).PRN) == 0
                E1mission = E1mission + double(m1.obsSolutions(j).cn0 > settings.threshold);
                E1idx(m1.obsSolutions(j).PRN) = 1;
            end
        case {'E5', 'E7', 'E8'} % E5 band
            if E5idx(m1.obsSolutions(j).PRN) == 0
                E5mission = E5mission + double(m1.obsSolutions(j).cn0 > settings.threshold);
                E5idx(m1.obsSolutions(j).PRN) = 1;
            end        
        case 'E6' % E6 band
            if E6idx(m1.obsSolutions(j).PRN) == 0
                E6mission = E6mission + double(m1.obsSolutions(j).cn0 > settings.threshold);
                E6idx(m1.obsSolutions(j).PRN) = 1;
            end
        case {'B1', 'B2'} % B1 band
            if B1idx(m1.obsSolutions(j).PRN) == 0
                B1mission = B1mission + double(m1.obsSolutions(j).cn0 > settings.threshold);
                B1idx(m1.obsSolutions(j).PRN) = 1;
            end
        case {'B5', 'B7', 'B8'} % B2 band
            if B2idx(m1.obsSolutions(j).PRN) == 0
                B2mission = B2mission + double(m1.obsSolutions(j).cn0 > settings.threshold);
                B2idx(m1.obsSolutions(j).PRN) = 1;
            end
        case 'B6' % B3 band
            if B3idx(m1.obsSolutions(j).PRN) == 0
                B3mission = B3mission + double(m1.obsSolutions(j).cn0 > settings.threshold);
                B3idx(m1.obsSolutions(j).PRN) = 1;
            end
    end
end

[GPStot, GLOtot, GALtot, BDStot] = countUniqueSvs(m1.obsSolutions, settings);

GNSStot = GPStot + GLOtot + GALtot + BDStot;

%% Time
%--- Time axis
timeIdx = floor(limit(1)):floor(limit(2));
time = datetime(cell2mat([epochDate(timeIdx,1) epochDate(timeIdx,2)]));

%--- Find start and end indexes
idx = findTimeLines(epochDate, settings);

%% Generate signal plot
h = figure(figureNum);
set(h,'Name','BandVisibility');
clf;

plot(time, L1mission(timeIdx),'Color',PRNColors("GPS L1"),'DisplayName',"GPS L1",'LineWidth',1.2);
hold on;
plot(time, L2mission(timeIdx),'Color',PRNColors("GPS L2"),'DisplayName',"GPS L2",'LineWidth',1.2);
plot(time, L5mission(timeIdx),'Color',PRNColors("GPS L5"),'DisplayName',"GPS L5",'LineWidth',1.2);

plot(time, G1mission(timeIdx),'Color',PRNColors("GLO G1"),'DisplayName',"GLO G1",'LineWidth',1.2);
plot(time, G2mission(timeIdx),'Color',PRNColors("GLO G2"),'DisplayName',"GLO G2",'LineWidth',1.2);
plot(time, G3mission(timeIdx),'Color',PRNColors("GLO G3"),'DisplayName',"GLO G3",'LineWidth',1.2);

plot(time, E1mission(timeIdx),'Color',PRNColors("Gal E1"),'DisplayName',"GAL E1",'LineWidth',1.2);
plot(time, E5mission(timeIdx),'Color',PRNColors("Gal E5"),'DisplayName',"GAL E5",'LineWidth',1.2);
plot(time, E6mission(timeIdx),'Color',PRNColors("Gal E6"),'DisplayName',"GAL E6",'LineWidth',1.2);

plot(time, B1mission(timeIdx),'Color',PRNColors("BDS B1"),'DisplayName',"BDS B1",'LineWidth',1.2);
plot(time, B2mission(timeIdx),'Color',PRNColors("BDS B2"),'DisplayName',"BDS B2",'LineWidth',1.2);
plot(time, B3mission(timeIdx),'Color',PRNColors("BDS B3"),'DisplayName',"BDS B3",'LineWidth',1.2);

%--- If we found start & end indexes, plot them
plotTimeLines(time, idx);

hold off;
%--- Specs of the plot
title(strcat(figureName," - Band Visibility"));
ylabel('Radiometric Visibility');
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
hLeg = legend('Location','Best','NumColumns',4,'FontSize',7);
hLeg.ItemHitFcn = @action1;

%--- Plot location
Pix_SS = get(0,'screensize');
h.OuterPosition = [Pix_SS(3)/2 Pix_SS(4)/2 Pix_SS(3)/4 Pix_SS(4)/2];

%--- Message
msg01 = strcat(figureName, " - Radiometric band visibility plot generated");

%% Generate constellation plot
h = figure(figureNum+1);
set(h,'Name','ConstellationVisibility');
clf;

plot(time, GPStot(timeIdx),'Color',PRNColors("GPS"),'DisplayName',"GPS",'LineWidth',1.2);
hold on;
plot(time, GLOtot(timeIdx),'Color',PRNColors("GLO"),'DisplayName',"GLO",'LineWidth',1.2);
plot(time, GALtot(timeIdx),'Color',PRNColors("Gal"),'DisplayName',"GAL",'LineWidth',1.2);
plot(time, BDStot(timeIdx),'Color',PRNColors("BDS"),'DisplayName',"BDS",'LineWidth',1.2);

plot(time, GNSStot(timeIdx),'Color',[0 0 0],'DisplayName',"GNSS",'LineWidth',1.1);

%--- If we found start & end indexes, plot them
plotTimeLines(time, idx);

hold off;
%--- Specs of the plot
title(strcat(figureName, " - Constellation Visibility"));
ylabel('Radiometric Visibility');
xlabel('Time');
ylim([0 max(GNSStot)]);
grid on;
xticks(time(ticksVector));
xticklabels(string(timeofday(time(ticksVector))));
subtitle(strcat("Start Date: ",epochDate{1,1},"  |  End Date: ",epochDate{ticksVector(6),1}))

%--- Add listener for datatips
datacursormode on;
dcm = datacursormode(h);
set(dcm,'UpdateFcn',@customDataTip);

%--- Legend
hLeg = legend('Location','Best');
hLeg.ItemHitFcn = @action1;

%--- Plot location
Pix_SS = get(0,'screensize');
h.OuterPosition = [Pix_SS(3)/2 Pix_SS(2) Pix_SS(3)/4 Pix_SS(4)/2];
hold off;

%--- Message
msg02 = strcat(figureName, " - Radiometric constellation visibility plot generated");

%% Generate outage (availability percentage) plot
GPSavail = double(GPStot(timeIdx) >= 4);
GPSperc = sum(GPSavail)*100/numel(timeIdx);
GPSavail(GPSavail == 0) = NaN;
GPSoutage = double(GPStot(timeIdx) >= 4);
GPSoutage(GPSoutage == 1) = NaN;

GLOavail = double(GLOtot(timeIdx) >= 4);
GLOperc = sum(GLOavail)*100/numel(timeIdx);
GLOavail(GLOavail == 0) = NaN;
GLOoutage = double(GLOtot(timeIdx) >= 4);
GLOoutage(GLOoutage == 1) = NaN;

GALavail = double(GALtot(timeIdx) >= 4);
GALperc = sum(GALavail)*100/numel(timeIdx);
GALavail(GALavail == 0) = NaN;
GALoutage = double(GALtot(timeIdx) >= 4);
GALoutage(GALavail == 1) = NaN;

BDSavail = double(BDStot(timeIdx) >= 4);
BDSperc = sum(BDSavail)*100/numel(timeIdx);
BDSavail(GPSavail == 0) = NaN;
BDSoutage = double(BDStot(timeIdx) >= 4);
BDSoutage(BDSoutage == 1) = NaN;


GNSSavail = double(GNSStot(timeIdx) >= 4);
GNSSperc = sum(GNSSavail)*100/numel(timeIdx);
GNSSavail(GNSSavail == 0) = NaN;
GNSSoutage = double(GNSStot(timeIdx) >= 4);
GNSSoutage(GNSSoutage == 1) = NaN;

if useNavFlag
    NAVavail = double(~isnan(m2.navSolutions.X));
    NAVperc = sum(NAVavail)*100/numel(timeIdx);
    NAVavail(NAVavail == 0) = NaN;
    NAVoutage = double(~isnan(m2.navSolutions.X));
    NAVoutage(NAVoutage == 1) = NaN;
else
    NAVavail = nan(size(timeIdx));
    NAVperc = 0;
    NAVoutage = zeros(size(timeIdx));
end

h = figure(figureNum + 2);
set(h,'Name','TelemetryAvailability');
clf;

%--- GPS
subplot(7,1,1);
plot(time, GPSavail,'marker','*','markersize',1,'color','blue','DisplayName',"Available");
hold on;
plot(time, GPSoutage,'marker','*','markersize',1,'color','red','DisplayName',"Unavailable");

text(time(25), 0., sprintf('Availability: %.2f %%', GPSperc), 'Horiz','left', 'Vert','bottom');
%--- If we found start & end indexes, plot them
plotTimeLines(time, idx);

%--- Specs
ylabel('Availability');
xlim('tight');
ylim([0 1]);
grid on;
xticks(time(ticksVector));
xticklabels(string(timeofday(time(ticksVector))));
title('GPS availability');

%--- GLONASS
subplot(7,1,2);
plot(time, GLOavail,'marker','*','markersize',1,'color','blue','DisplayName',"Available");
hold on;
plot(time, GLOoutage,'marker','*','markersize',1,'color','red','DisplayName',"Unvailable");

text(time(25), 0, sprintf('Availability: %.2f %%', GLOperc), 'Horiz','left', 'Vert','bottom');
%--- If we found start & end indexes, plot them
plotTimeLines(time, idx);

ylabel('Availability');
xlim('tight');
ylim([0 1]);
grid on;
xticks(time(ticksVector));
xticklabels(string(timeofday(time(ticksVector))));
title('GLO Availability');

%--- Galileo
subplot(7,1,3);
plot(time, GALavail,'marker','*','markersize',1,'color','blue','DisplayName',"Available");
hold on;
plot(time, GALoutage,'marker','*','markersize',1,'color','red','DisplayName',"Unvailable");

text(time(25), 0, sprintf('Availability: %.2f %%', GALperc), 'Horiz','left', 'Vert','bottom');
%--- If we found start & end indexes, plot them
plotTimeLines(time, idx);

ylabel('Availability');
xlim('tight');
ylim([0 1]);
grid on;
xticks(time(ticksVector));
xticklabels(string(timeofday(time(ticksVector))));
title('GAL Availability');

%--- BeiDou
subplot(7,1,4);
plot(time, BDSavail,'marker','*','markersize',1,'color','blue','DisplayName',"Available");
hold on;
plot(time, BDSoutage,'marker','*','markersize',1,'color','red','DisplayName',"Unvailable");

text(time(25), 0, sprintf('Availability: %.2f %%', BDSperc), 'Horiz','left', 'Vert','bottom');
%--- If we found start & end indexes, plot them
plotTimeLines(time, idx);

ylabel('Availability');
xlim('tight');
ylim([0 1]);
grid on;
xticks(time(ticksVector));
xticklabels(string(timeofday(time(ticksVector))));
title('BDS Availability');

%--- GNSS with GGTO
subplot(7,1,6);
plot(time, GNSSavail,'marker','*','markersize',1,'color','blue','DisplayName',"Available");
hold on;
plot(time, GNSSoutage,'marker','*','markersize',1,'color','red','DisplayName',"Unavailable");

text(time(25), 0, sprintf('Availability: %.2f %%', GNSSperc), 'Horiz','left', 'Vert','bottom');
%--- If we found start & end indexes, plot them
plotTimeLines(time, idx);

ylabel('Availability');
xlim('tight');
ylim([0 1]);
grid on;
xticks(time(ticksVector));
xticklabels(string(timeofday(time(ticksVector))));
title('GNSS Availability (demodulate inter-system bias)');

%--- NAV solutions
subplot(7,1,7);
if useNavFlag
    plot(time, NAVavail,'marker','*','markersize',1,'color','blue','DisplayName',"Available");
    hold on;
    plot(time, NAVoutage,'marker','*','markersize',1,'color','red','DisplayName',"Unavailable");

    text(time(25), 0, sprintf('Availability: %.2f %%', NAVperc), 'Horiz','left', 'Vert','bottom');
else
    plot(time, nan(numel(timeIdx),1));
    text(time(floor(end/5)),0.5,'No PVT available');
end
ylabel('Availability');
xlabel('Time');
xlim([time(1) time(end)]);
ylim([0 1]);
grid on;
xticks(time(ticksVector));
xticklabels(string(timeofday(time(ticksVector))));
title('NMEA solution Availability');

%--- Add listener for datatips
datacursormode on;
dcm = datacursormode(h);
set(dcm,'UpdateFcn',@customDataTip);

%--- Plot location
Pix_SS = get(0,'screensize');
h.OuterPosition = [3*Pix_SS(3)/4 Pix_SS(2) Pix_SS(3)/4 Pix_SS(4)];

%--- Message
msg03 = strcat(figureName, " - Availability plot generated");