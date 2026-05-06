function [L1outliers, L5outliers, msg] = PlotDoubleCMC(directory, file, limit, epochDate, settings, varargin)
% This function generates the double frequency CMC plot 
%
% Written by Yihan Guo
% Adapted to LuNART-Q by Simone Zocca, Alex Minetto

if ~isempty(varargin)
    figureNum = varargin{1};
else
    figureNum = 900;
end

%--- Load files
path = fullfile(directory,file);
m = load(path);

%% --- Calculate CMC on two furthest bands
L1outliers = [];
L5outliers = [];

%--- Keep a list of PRNs present for each of the three bands
prnIdx = FindMultiFreqIndexes(m.obsSolutions);

%--- Initialize three CMC
cmcB1 = NaN(size(prnIdx,2),size(m.obsSolutions(1).rawP,2));
cmcB2 = NaN(size(prnIdx,2),size(m.obsSolutions(1).rawP,2));
cmcB1_m = NaN(size(prnIdx,2),size(m.obsSolutions(1).rawP,2));
cmcB2_m = NaN(size(prnIdx,2),size(m.obsSolutions(1).rawP,2));

for i = 1:size(prnIdx,2)
    if sum(~isnan(prnIdx(:,i))) == 2

        cString = char(m.obsSolutions(prnIdx(1,i)).SV);
        if settings.(cString(1:3))
            
            f1 = m.obsSolutions(prnIdx(1,i)).freq;
            f2 = m.obsSolutions(prnIdx(2,i)).freq;
            coeff1 = 2 * f2^2 / (f1^2 - f2^2);
            coeff2 = 2 * f1^2 / (f2^2 - f1^2);

            P1 = m.obsSolutions(prnIdx(1,i)).rawP;
            P2 = m.obsSolutions(prnIdx(2,i)).rawP;
            L1 = m.obsSolutions(prnIdx(1,i)).CarrierPhase * physconst('lightspeed') / m.obsSolutions(prnIdx(1,i)).freq;
            L2 = m.obsSolutions(prnIdx(2,i)).CarrierPhase * physconst('lightspeed') / m.obsSolutions(prnIdx(1,i)).freq;

            cmcB1(i,:) = P1 - L1 - coeff1 * (L1 - L2);
            cmcB2(i,:) = P2 - L2 - coeff2 * (L2 - L1);

             %--- Remove mean using first derivative
            cmcB1_m(i,1:end-3) = centralFiniteDiff(cmcB1(i,:), 2, 3);
            cmcB2_m(i,1:end-3) = centralFiniteDiff(cmcB2(i,:), 2, 3);
        end
    end
end

%--- Time axis
timeIdx = floor(limit(1)):floor(limit(2));
time = datetime(cell2mat([epochDate(timeIdx,1) epochDate(timeIdx,2)]));

%% Generate plot
h = figure(figureNum);
set(h,'Name','DoubleCMC');

subplot(2, 1, 1)
%--- Band 1
for i = 1:size(prnIdx,2)
    if sum(~isnan(prnIdx(:,i))) == 2

        cString = char(m.obsSolutions(prnIdx(1,i)).SV);
        if settings.(cString(1:3))
            %--- Find the right color
            svID = m.obsSolutions(prnIdx(1,i)).SV;
            RGBcolor = PRNColors(svID);

            plot(time, cmcB1_m(i,timeIdx),'-','Color',RGBcolor,'MarkerSize',2,'DisplayName',append(svID," ",m.obsSolutions(prnIdx(1,i)).band," (",m.obsSolutions(prnIdx(2,i)).band,")"),'LineWidth',1.1);
            hold on;
            if settings.findOutliers
                table = hlSigmaOutliers(time, cmcB1_m(i,timeIdx), m.obsSolutions(prnIdx(1,i)).SV, settings.window, settings.threshold, RGBcolor);
                L1outliers = vertcat(L1outliers, table);
            end
        end
    end
end

hold off;
%--- Specs of the plot
ylabel('Detrended 2F CMC [m]');
title('Band 1');
axis tight;
grid on;
ticksVector = getTicks(limit);
xticks(time(ticksVector));
xticklabels(string(timeofday(time(ticksVector))));

%--- Legend
hLeg = legend('Location','eastoutside','NumColumns',2,'FontSize',8);
hLeg.ItemHitFcn = @action1;

%--- L5/E5
subplot(2, 1, 2)
for i = 1:size(prnIdx,2)
    if sum(~isnan(prnIdx(:,i))) == 2

        cString = char(m.obsSolutions(prnIdx(1,i)).SV);
        if settings.(cString(1:3))
            %--- Find the right color
            svID = m.obsSolutions(prnIdx(1,i)).SV;
            RGBcolor = PRNColors(svID);

            plot(time, cmcB2_m(i,timeIdx),'-','Color',RGBcolor,'MarkerSize',2,'DisplayName',append(svID," ",m.obsSolutions(prnIdx(2,i)).band," (",m.obsSolutions(prnIdx(1,i)).band,")"),'LineWidth',1.1);
            hold on;
            if settings.findOutliers
                table = hlSigmaOutliers(time, cmcB2_m(i,timeIdx), m.obsSolutions(prnIdx(2,i)).SV, settings.window, settings.threshold, RGBcolor);
                L5outliers = vertcat(L5outliers, table);
            end
        end
    end
end

hold off;
%--- Specs of the plot
ylabel('Detrended 2F CMC [m]');
title('Band 2');
xlabel('Time');
axis tight;
grid on;
ticksVector = getTicks(limit);
xticks(time(ticksVector));
xticklabels(string(timeofday(time(ticksVector))));

sgt = sgtitle({['{\bf' 'RINEX Obs - Detrended 2F CMC' '}'], strcat("Start Date: ",epochDate{1,1},"  |  End Date: ",epochDate{ticksVector(6),1})});
sgt.FontSize = 11;

%--- Add listener for datatips
datacursormode on;
dcm = datacursormode(h);
set(dcm,'UpdateFcn',@customDataTip);

%--- Legend
hLeg = legend('Location','eastoutside','NumColumns',2,'FontSize',8);
hLeg.ItemHitFcn = @action1;

%--- Title and plot location
Pix_SS = get(0,'screensize');
h.OuterPosition = [Pix_SS(3)/2 0 Pix_SS(3)/2 Pix_SS(4)];

msg = "Detrended 2F CMC plot generated";

%% --- Handle tables (generate as figures)
if settings.findOutliers
    if ~isempty(L1outliers)
        numRows = height(L1outliers);
        %--- Create the new column with the same number of rows as the table
        newColumn = repmat({'L1/E1'}, numRows, 1);
        %--- Add the new column to the table
        L1outliers.channel = newColumn;
        %--- Rearrange the column order
        L1outliers = L1outliers(:, [width(L1outliers), 1:width(L1outliers)-1]);
    end

    if ~isempty(L5outliers)
        numRows = height(L5outliers);
        %--- Create the new column with the same number of rows as the table
        newColumn = repmat({'L5/E5'}, numRows, 1);
        %--- Add the new column to the table
        L5outliers.channel = newColumn;
        %--- Rearrange the column order
        L5outliers = L5outliers(:, [width(L5outliers), 1:width(L5outliers)-1]);
    end

    h = figure(figureNum + 1);
    if ~isempty(L5outliers) || ~isempty(L1outliers)
        outliersT = vertcat(L1outliers,L5outliers);
        uitable('Data',outliersT{:,:},'ColumnName',outliersT.Properties.VariableNames,'RowName',outliersT.Properties.RowNames,'Units', 'Normalized', 'Position',[0, 0, 1, 1]);
    else
        f = uitable('Data',{'No outliers detected'});
        f.ColumnWidth = {100};
    end
    h.OuterPosition = [3*Pix_SS(3)/4 0 Pix_SS(3)/4 Pix_SS(4)/2];
    h.WindowState = 'minimized';
end