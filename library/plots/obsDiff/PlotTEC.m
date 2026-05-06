function [msg] = PlotTEC(directory, file, limit, epochDate, settings, varargin)
% This function generates slant TEC plot 
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

%--- Keep a list of PRNs present for each of the three bands
prnIdx = FindMultiFreqIndexes(m.obsSolutions);

%--- Time axis
timeIdx = floor(limit(1)):floor(limit(2));
time = datetime(cell2mat([epochDate(timeIdx,1) epochDate(timeIdx,2)]));

%% Generate plot
h = figure(figureNum);
set(h,'Name','SlantTEC');

%--- Compute TEC
for i = 1:size(prnIdx,2)
    %--- Check is at least two frequencies are present in the data
    if sum(~isnan(prnIdx(:,i))) == 2

        cString = char(m.obsSolutions(prnIdx(1,i)).SV);
        hold on;
        if settings.(cString(1:3))
            %--- Coefficients
            f1 = m.obsSolutions(prnIdx(1,i)).freq;
            f2 = m.obsSolutions(prnIdx(2,i)).freq;
            cf1 = f1^2 / (f1^2 - f2^2);
            cf2 = f2^2 / (f1^2 - f2^2);
            %--- Measurements
            P1 = m.obsSolutions(prnIdx(1,i)).rawP;
            P2 = m.obsSolutions(prnIdx(2,i)).rawP;
            %--- Compute values
            ionoError = (P1.*cf1) - (P2.*cf2);
            ionoFree1 = P1 - ionoError;
            STEC = ionoFree1.*( f1^2 / 40.3e16 );
            %TEC = ( f1^2 * f2^2 / (40.3 * (f1^2  - f2^2) )).*(P1 - P2);

            %--- Find the right color
            svID = m.obsSolutions(prnIdx(1,i)).SV;
            RGBcolor = PRNColors(svID);

            plot(time,STEC(timeIdx),'Color',RGBcolor,'MarkerSize', 2,'DisplayName',append(svID," ",m.obsSolutions(prnIdx(1,i)).band,"+",m.obsSolutions(prnIdx(2,i)).band),'LineWidth',1.1);
        end
    end
end

xlabel('Time');
ylabel('Slant TEC [TECu]');
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

%--- Place on screen
title("RINEX Obs - Slant TEC");
Pix_SS = get(0,'screensize');
h.OuterPosition = [Pix_SS(3)/2 0 Pix_SS(3)/2 Pix_SS(4)/2];

%--- Message
msg = "Slant TEC plot generated";