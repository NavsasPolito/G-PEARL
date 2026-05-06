function [navSolutions] = NavParser(path)
%% NMEA Parser for GNSS navigation files 
% 
%
% Written by Simone Zocca

%% Parse messages using MATLAB functions
%--- Opean file and read
fileID = fopen(path,'r');
gnssData = fscanf(fileID,'%c');

%--- Create NMEA parser object to read different messages
parserGGA = nmeaParser('MessageId','GGA');
parserRMC = nmeaParser('MessageId','RMC');
parserGSA = nmeaParser('MessageId','GSA');

%--- Parse message
ggaData = parserGGA(gnssData);
rmcData = parserRMC(gnssData);
gsaData = parserGSA(gnssData);

%% Create consistent time axis
%--- Find first epoch where gga time is not NaT
time = NaT(1, numel(ggaData));

for i = 1:length(ggaData)
    time(i) = datetime(rmcData(i).UTCDateTime.Year, rmcData(i).UTCDateTime.Month, rmcData(i).UTCDateTime.Day, ...
        ggaData(i).UTCTime.Hour, ggaData(i).UTCTime.Minute, ggaData(i).UTCTime.Second);
end
timeCln = time(~isnat(time));
timeIdx = cumsum(~isnat(time));

%--- Initialize
navSolutions.UTCtime          = timeCln;
navSolutions.UTCtime.Format   = 'yyyy-MM-dd HH:mm';
navSolutions.UTCtime.TimeZone = 'UTC';

%% Parse the other data
navSolutions.latitude   = NaN(1, numel(timeCln));
navSolutions.longitude  = NaN(1, numel(timeCln));
navSolutions.height     = NaN(1, numel(timeCln));
navSolutions.X          = NaN(1, numel(timeCln));
navSolutions.Y          = NaN(1, numel(timeCln));
navSolutions.Z          = NaN(1, numel(timeCln));
navSolutions.DOP        = NaN(5, numel(timeCln));
navSolutions.nSat       = NaN(1, numel(timeCln));

for i = 1:length(time)
    %--- Status = 0 means data is valid
    if ggaData(i).Status == 0 && ~isnat(time(i))
        % THINGS TO BE IMPROVED:
        % 
        % - We assume they have same timestamp, need to check!
        % - Can take timezone from ZDA message
        % - Can take error statistics from GTS message

        navSolutions.latitude(timeIdx(i))  = ggaData(i).Latitude;
        navSolutions.longitude(timeIdx(i)) = ggaData(i).Longitude;
        navSolutions.height(timeIdx(i))    = ggaData(i).Altitude + ggaData(i).GeoidSeparation; % Check if correct

        p = lla2ecef([ggaData(i).Latitude ggaData(i).Longitude ggaData(i).Altitude]);
        navSolutions.X(timeIdx(i)) = p(1);
        navSolutions.Y(timeIdx(i)) = p(2);
        navSolutions.Z(timeIdx(i)) = p(3);

        navSolutions.nSat(timeIdx(i))  = ggaData(i).NumSatellitesInUse;
        navSolutions.DOP(3,timeIdx(i)) = ggaData(i).HDOP;
    end
end