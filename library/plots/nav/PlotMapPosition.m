function [msg01] = PlotMapPosition(directory, file, limit, epochDate, varargin)
% This function plots the trajectory using geoplot
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

%--- Generate plot
h = figure(figureNum);
set(h,'Name','Position');
clf;

geoplot(m.navSolutions.latitude(timeIdx),m.navSolutions.longitude(timeIdx),'LineWidth',1.1,'DisplayName','NAV');
if exist('m2','var') && ~isempty(m2)
    hold on;
    geoplot(m2.navSolutions.Latitude(timeIdx),m2.navSolutions.Longitute(timeIdx),'k--','LineWidth',1.1,'DisplayName','REF');
end
geobasemap topographic

grid on;
ticksVector = getTicks(limit);
title('NMEA - Trajectory');
subtitle(strcat("Start Date: ",epochDate{1,1},"  |  End Date: ",epochDate{ticksVector(6),1}));

%--- Legend
hLeg = legend('Location','Best');
%hLeg.ItemHitFcn = @action1;

%--- Plot location
Pix_SS = get(0,'screensize');
h.OuterPosition = [Pix_SS(3)/2 Pix_SS(4)/2 Pix_SS(3)/2 Pix_SS(4)/2];

msg01 = "NMEA - Trajectory plot generated";