function [obsSolutions] = RinexParser(path)
%% RinexParser for Mixed Observation Data RINEX files 
% The Parser has most operations repeated four times, one for each constellation
%
% Written by Simone Zocca

%--- Load the file and generate a table (time consuming part)
tableRaw = rinexread(path);

%% --- Extract table data and save a flag and PRN list for each constellation 
try     
    tableGPS = timetable2table(tableRaw.GPS);
    [infoGPS.PRN] = unique(tableGPS.SatelliteID);
    infoGPS.PRN(isnan(infoGPS.PRN)) = []; % Remove possible NaN
    infoGPS.flag = 1;
catch
    fprintf('Warning! No GPS Data.\n');
    infoGPS.flag = 0;
end
try
    tableGLO = timetable2table(tableRaw.GLONASS);    
    [infoGLO.PRN] = unique(tableGLO.SatelliteID);
    infoGLO.PRN(isnan(infoGLO.PRN)) = []; % Remove possible NaN
    infoGLO.flag = 1;
catch
    fprintf('Warning! No GLONASS Data.\n');
    infoGLO.flag = 0;
end
try
    tableGAL = timetable2table(tableRaw.Galileo);
    [infoGAL.PRN] = unique(tableGAL.SatelliteID);
    infoGAL.PRN(isnan(infoGAL.PRN)) = []; % Remove possible NaN
    infoGAL.flag = 1;
catch
    fprintf('Warning! No Galileo Data.\n');
    infoGAL.flag = 0;
end
try
    tableBEI = timetable2table(tableRaw.BeiDou);
    [infoBDS.PRN] = unique(tableBEI.SatelliteID);
    infoBDS.PRN(isnan(infoBDS.PRN)) = []; % Remove possible NaN
    infoBDS.flag = 1;
catch
    fprintf('Warning! No BeiDou Data.\n');
    infoBDS.flag = 0;
end
fprintf('File loaded, tables for each constellation have been generated.\n');
clear path tableRaw

%% Find which channel and codes are present
%--- GPS
infoGPS.existCodes = ["1C";"1S";"1L";"1X";"1P";"1W";"1Y";"1M";"2C";"2D";"2S";"2L";"2X";"2P";"2W";"2Y";"2M";"5I";"5Q";"5X"];
infoGPS.codes = [];
if infoGPS.flag == 1
    infoGPS.fields = fieldnames(tableGPS);
    for i = 1:size(infoGPS.existCodes)
        idx = endsWith(infoGPS.fields,infoGPS.existCodes(i,:));
        if sum(idx) >= 1
            infoGPS.codes = [infoGPS.codes; infoGPS.existCodes(i,:)];
        end
    end
end
%--- GLONASS
infoGLO.existCodes = ["1C";"1P";"4A";"4B";"4X";"2C";"2P";"6A";"6B";"6X";"3I";"3Q";"3X"];
infoGLO.codes = [];
if infoGLO.flag == 1
    infoGLO.fields = fieldnames(tableGLO);
    for i = 1:size(infoGLO.existCodes)
        idx = endsWith(infoGLO.fields,infoGLO.existCodes(i,:));
        if sum(idx) >= 1
            infoGLO.codes = [infoGLO.codes; infoGLO.existCodes(i,:)];
        end
    end
end
%--- Galileo
infoGAL.existCodes = ["1A";"1B";"1C";"1X";"1Z";"5I";"5Q";"5X";"7I";"7Q";"7X";"8I";"8Q";"8X";"6A";"6B";"6C";"6X";"6Z"];
infoGAL.codes = [];
if infoGAL.flag == 1
    infoGAL.fields = fieldnames(tableGAL);
    for i = 1:size(infoGAL.existCodes)
        idx = endsWith(infoGAL.fields,infoGAL.existCodes(i,:));
        if sum(idx) >= 1
            infoGAL.codes = [infoGAL.codes; infoGAL.existCodes(i,:)];
        end
    end
end
%--- BeiDou
infoBDS.existCodes = ["1I";"2I";"2Q";"2X";"1D";"1P";"1X";"1S";"1L";"1Z";"5D";"5P";"5X";"7I";"7Q";"7X";"7D";"7P";"7Z";"8D";"8P";"8X";"6I";"6Q";"6X";"6D";"6P";"6Z"];
infoBDS.codes = [];
if infoBDS.flag == 1
    infoBDS.fields = fieldnames(tableBEI);
    for i = 1:size(infoBDS.existCodes)
        idx = endsWith(infoBDS.fields,infoBDS.existCodes(i,:));
        if sum(idx) >= 1
            infoBDS.codes = [infoBDS.codes; infoBDS.existCodes(i,:)];
        end
    end
end
clear idx

%% --- Initialize dedicated MATLAB structures
%--- GPS
infoGPS.nCodes = size(infoGPS.codes,1);
if infoGPS.flag == 1
    for i = 1:length(infoGPS.PRN)
        for j = 1:infoGPS.nCodes
            dataGPS(infoGPS.nCodes*i+j-infoGPS.nCodes).PRN = infoGPS.PRN(i,1);
            dataGPS(infoGPS.nCodes*i+j-infoGPS.nCodes).SV = strcat("GPS",num2str(infoGPS.PRN(i,1),'%.2u'));
            dataGPS(infoGPS.nCodes*i+j-infoGPS.nCodes).channel = char(strcat("L",infoGPS.codes(j)));

            channel = char(infoGPS.codes(j));
            switch channel(1)
                case '1'
                    dataGPS(infoGPS.nCodes*i+j-infoGPS.nCodes).band = "L1";
                    dataGPS(infoGPS.nCodes*i+j-infoGPS.nCodes).freq = 1.57542E9;
                case '2'
                    dataGPS(infoGPS.nCodes*i+j-infoGPS.nCodes).band = "L2";
                    dataGPS(infoGPS.nCodes*i+j-infoGPS.nCodes).freq = 1.22760E9;
                case '5'
                    dataGPS(infoGPS.nCodes*i+j-infoGPS.nCodes).band = "L5";
                    dataGPS(infoGPS.nCodes*i+j-infoGPS.nCodes).freq = 1.17645E9;
                otherwise
                    dataGPS(infoGPS.nCodes*i+j-infoGPS.nCodes).band = "Unknown Band";
                    dataGPS(infoGPS.nCodes*i+j-infoGPS.nCodes).freq = NaN;
            end
        end
    end
else
    dataGPS = [];
end
%--- GLONASS
infoGLO.nCodes = size(infoGLO.codes,1);
if infoGLO.flag == 1
    for i = 1:length(infoGLO.PRN)
        for j =1:infoGLO.nCodes
            dataGLONASS(infoGLO.nCodes*i+j-infoGLO.nCodes).PRN = infoGLO.PRN(i,1);
            dataGLONASS(infoGLO.nCodes*i+j-infoGLO.nCodes).SV = strcat("GLO",num2str(infoGLO.PRN(i,1),'%.2u'));
            dataGLONASS(infoGLO.nCodes*i+j-infoGLO.nCodes).channel = char(strcat("G",infoGLO.codes(j)));

            channel = char(infoGLO.codes(j));
            switch channel(1)
                case '1'
                    dataGLONASS(infoGLO.nCodes*i+j-infoGLO.nCodes).band = "G1";
                    dataGLONASS(infoGLO.nCodes*i+j-infoGLO.nCodes).freq = 1.602E9;
                case '2'
                    dataGLONASS(infoGLO.nCodes*i+j-infoGLO.nCodes).band = "G2";
                    dataGLONASS(infoGLO.nCodes*i+j-infoGLO.nCodes).freq = 1.246E9;
                case '3'
                    dataGLONASS(infoGLO.nCodes*i+j-infoGLO.nCodes).band = "G3";
                    dataGLONASS(infoGLO.nCodes*i+j-infoGLO.nCodes).freq = 1.202025E9;
                case '4'
                    dataGLONASS(infoGLO.nCodes*i+j-infoGLO.nCodes).band = "G1a";
                    dataGLONASS(infoGLO.nCodes*i+j-infoGLO.nCodes).freq = 1.60099E9;
                case '6'
                    dataGLONASS(infoGLO.nCodes*i+j-infoGLO.nCodes).band = "G2a";
                    dataGLONASS(infoGLO.nCodes*i+j-infoGLO.nCodes).freq = 1.24806E9;
                otherwise
                    dataGLONASS(infoGLO.nCodes*i+j-infoGLO.nCodes).band = "Unknown Band";
                    dataGLONASS(infoGLO.nCodes*i+j-infoGLO.nCodes).freq = NaN;
            end
        end
    end
else
    dataGLONASS = [];
end
%--- Galileo
infoGAL.nCodes = size(infoGAL.codes,1);
if infoGAL.flag == 1
    for i = 1:length(infoGAL.PRN)
        for j = 1:infoGAL.nCodes
            dataGalileo(infoGAL.nCodes*i+j-infoGAL.nCodes).PRN = infoGAL.PRN(i,1);
            dataGalileo(infoGAL.nCodes*i+j-infoGAL.nCodes).SV = strcat("GAL",num2str(infoGAL.PRN(i,1),'%.2u'));
            dataGalileo(infoGAL.nCodes*i+j-infoGAL.nCodes).channel = char(strcat("E",infoGAL.codes(j)));

            channel = char(infoGAL.codes(j));
            switch channel(1)
                case '1'
                    dataGalileo(infoGAL.nCodes*i+j-infoGAL.nCodes).band = "E1";
                    dataGalileo(infoGAL.nCodes*i+j-infoGAL.nCodes).freq = 1.57542E9;
                case '5'
                    dataGalileo(infoGAL.nCodes*i+j-infoGAL.nCodes).band = "E5a";
                    dataGalileo(infoGAL.nCodes*i+j-infoGAL.nCodes).freq = 1.17645E9;
                case '6'
                    dataGalileo(infoGAL.nCodes*i+j-infoGAL.nCodes).band = "E6";
                    dataGalileo(infoGAL.nCodes*i+j-infoGAL.nCodes).freq = 1.27875E9;
                case '7'
                    dataGalileo(infoGAL.nCodes*i+j-infoGAL.nCodes).band = "E5b";
                    dataGalileo(infoGAL.nCodes*i+j-infoGAL.nCodes).freq = 1.207140E9;
                case '8'
                    dataGalileo(infoGAL.nCodes*i+j-infoGAL.nCodes).band = "E5(a+b)";
                    dataGalileo(infoGAL.nCodes*i+j-infoGAL.nCodes).freq = 1.191795E9;
                otherwise
                    dataGalileo(infoGAL.nCodes*i+j-infoGAL.nCodes).band = "Unknown Band";
                    dataGalileo(infoGAL.nCodes*i+j-infoGAL.nCodes).freq = NaN;
            end
        end
    end
else
    dataGalileo = [];
end
%--- BeiDou
infoBDS.nCodes = size(infoBDS.codes,1);
if infoBDS.flag == 1
    for i = 1:length(infoBDS.PRN)
        for j = 1:infoBDS.nCodes
            dataBeiDou(infoBDS.nCodes*i+j-infoBDS.nCodes).PRN = infoBDS.PRN(i,1);
            dataBeiDou(infoBDS.nCodes*i+j-infoBDS.nCodes).SV = strcat("BDS",num2str(infoBDS.PRN(i,1),'%.2u'));
            dataBeiDou(infoBDS.nCodes*i+j-infoBDS.nCodes).channel = char(strcat("B",infoBDS.codes(j)));

            channel = char(infoBDS.codes(j));
            switch channel(1)
                case '1'
                    dataBeiDou(infoBDS.nCodes*i+j-infoBDS.nCodes).band = "B1";
                    dataBeiDou(infoBDS.nCodes*i+j-infoBDS.nCodes).freq = 1.57542E9;
                case '2'
                    dataBeiDou(infoBDS.nCodes*i+j-infoBDS.nCodes).band = "B1-2";
                    dataBeiDou(infoBDS.nCodes*i+j-infoBDS.nCodes).freq = 1.561098E9;
                case '5'
                    dataBeiDou(infoBDS.nCodes*i+j-infoBDS.nCodes).band = "B2a";
                    dataBeiDou(infoBDS.nCodes*i+j-infoBDS.nCodes).freq = 1.17645E9;
                case '6'
                    dataBeiDou(infoBDS.nCodes*i+j-infoBDS.nCodes).band = "B3";
                    dataBeiDou(infoBDS.nCodes*i+j-infoBDS.nCodes).freq = 1.26852E9;
                case '7'
                    dataBeiDou(infoBDS.nCodes*i+j-infoBDS.nCodes).band = "B2b";
                    dataBeiDou(infoBDS.nCodes*i+j-infoBDS.nCodes).freq = 1.207140E9;
                case '8'
                    dataBeiDou(infoBDS.nCodes*i+j-infoBDS.nCodes).band = "B2(a+b)";
                    dataBeiDou(infoBDS.nCodes*i+j-infoBDS.nCodes).freq = 1.191795E9;
                otherwise
                    dataBeiDou(infoBDS.nCodes*i+j-infoBDS.nCodes).band = "Unknown Band";
                    dataBeiDou(infoBDS.nCodes*i+j-infoBDS.nCodes).freq = NaN;
            end
        end
    end
else
    dataBeiDou = [];
end

clear channel

%% Search the weekNumber and GPStime. For this case in order to respect the time,
% when there is no information regarding the SV in a specified Epoch, the time will be NaN

%--- Each unique time is an Epoch. A table with the unique time samples is obtain in "dateTimeEpoch".
if infoGPS.flag == 1 
    auxdateTime.GPS = unique(tableGPS.Time);
else
    auxdateTime.GPS = [];
end
if infoGLO.flag == 1
    auxdateTime.GLONASS = unique(tableGLO.Time);
else
    auxdateTime.GLONASS = [];
end
if infoGAL.flag == 1
    auxdateTime.Galileo = unique(tableGAL.Time);
else
    auxdateTime.Galileo = [];
end
if infoBDS.flag == 1
    auxdateTime.BeiDou = unique(tableBEI.Time);
else
    auxdateTime.BeiDou = [];
end
auxdateTimeEpoch = [auxdateTime.GPS; auxdateTime.GLONASS; auxdateTime.Galileo; auxdateTime.BeiDou];
dateTimeEpoch = unique(auxdateTimeEpoch,'sorted');
clear auxdateTimeEpoch auxdateTime

%--- Now that the unique times are obtained, the weekNumber is established as the first dateTime
time.GPS0 = datetime(1980,1,6,0,0,0,'TimeZone','UTCLeapSeconds');
%time.startDate = dateTimeEpoch(1,1);
%time.startDate.TimeZone = 'UTCLeapSeconds';
dateTimeEpoch.TimeZone = 'UTCLeapSeconds';
deltaT = dateTimeEpoch - time.GPS0; 
deltaT.Format = 's';
time.weekNumber = floor(seconds(deltaT)/(7*86400));
time.dateSecondsEpoch = seconds(rem(deltaT,seconds(7*86400)));

if infoGPS.flag == 1
    for i = 1:(length(infoGPS.PRN)*infoGPS.nCodes)
        dataGPS(i).weekNumber = time.weekNumber;
        dataGPS(i).GPStime = time.dateSecondsEpoch;
    end
end
if infoGLO.flag == 1
    for i = 1:(length(infoGLO.PRN)*infoGLO.nCodes)
        dataGLONASS(i).weekNumber = time.weekNumber;
        dataGLONASS(i).GPStime = time.dateSecondsEpoch;
    end
end
if infoGAL.flag == 1
    for i = 1:(length(infoGAL.PRN)*infoGAL.nCodes)
        dataGalileo(i).weekNumber = time.weekNumber;
        dataGalileo(i).GPStime = time.dateSecondsEpoch;
    end
end
if infoBDS.flag == 1
    for i = 1:(length(infoBDS.PRN)*infoBDS.nCodes)
        dataBeiDou(i).weekNumber = time.weekNumber;
        dataBeiDou(i).GPStime = time.dateSecondsEpoch;
    end
end

clear  deltaT

%% For each PRN of each constellation we obtain the GPS time, Doppler, Pseudorange and CN0. 
%
%----------------------------- GPS ----------------------------------------
fprintf('Parsing GPS PRNs: ');
if infoGPS.flag == 1
    for k = 1:height(infoGPS.PRN)
        %--- Initialize time-series as NaN
        satPseudorange = NaN([height(dateTimeEpoch) 1]);
        satCarrPhase = NaN([height(dateTimeEpoch) 1]);
        satDoppler = NaN([height(dateTimeEpoch) 1]);
        satCN0 = NaN([height(dateTimeEpoch) 1]);

        %--- Now, we obtain the samples for each SV
        satelliteG = tableGPS(tableGPS.SatelliteID == infoGPS.PRN(k),:);
        
        %--- Extract observables for each available channel/code for the k-th PRN
        for i = 1:infoGPS.nCodes

            %--- Obtain index when PRN is present
            satelliteG.Time.TimeZone = 'UTCLeapSeconds';
            [~, idx1] = intersect(dateTimeEpoch, satelliteG.Time);

            %-- Code-based raw pseudorange in (m)
            if any(append("C",infoGPS.codes(i,:)) == string(infoGPS.fields))
                satPseudorange(idx1,1) = satelliteG.(append("C",infoGPS.codes(i,:)));
            end

            %-- Carrier-phase range in (cycles) [with ambiguity!]
            if any(append("L",infoGPS.codes(i,:)) == string(infoGPS.fields))
                satCarrPhase(idx1,1) = satelliteG.(append("L",infoGPS.codes(i,:)));
            end
            
            %-- Doppler-shift in (Hz)
            if any(append("D",infoGPS.codes(i,:)) == string(infoGPS.fields))
                satDoppler(idx1,1) = satelliteG.(append("D",infoGPS.codes(i,:)));
            end

            %-- C/N0 in (dBHz)
            if any(append("S",infoGPS.codes(i,:)) == string(infoGPS.fields))
                satCN0(idx1,1) = satelliteG.(append("S",infoGPS.codes(i,:)));
            end
                        
            %--- Store the data in the correspondent row of the output
            dataGPS(infoGPS.nCodes*k+i-infoGPS.nCodes).Doppler = transpose(satDoppler);
            dataGPS(infoGPS.nCodes*k+i-infoGPS.nCodes).rawP = transpose(satPseudorange);
            dataGPS(infoGPS.nCodes*k+i-infoGPS.nCodes).CarrierPhase = transpose(satCarrPhase);
            dataGPS(infoGPS.nCodes*k+i-infoGPS.nCodes).cn0 = transpose(satCN0);          
        end

        clear satelliteG
        fprintf('%.2u ',infoGPS.PRN(k));
    end
    fprintf('\n');

    % Delete empty rows  (SV has no data for a given signal)
    j = 0;
    for i = 1:(length(infoGPS.PRN)*infoGPS.nCodes)
        if  sum(~isnan(dataGPS(i-j).rawP)) == 0
            dataGPS(i-j) = [];
            j = j+1;
        end
    end
end

%----------------------------- GLONASS ------------------------------------
fprintf('Parsing GLONASS PRNs: ');
if infoGLO.flag == 1
    for k = 1:height(infoGLO.PRN)
        %--- Initialize time-series as NaN
        satPseudorange = NaN([height(dateTimeEpoch) 1]);
        satCarrPhase = NaN([height(dateTimeEpoch) 1]);
        satDoppler = NaN([height(dateTimeEpoch) 1]);
        satCN0 = NaN([height(dateTimeEpoch) 1]);

        %--- Now, we obtain the samples for each SV
        satelliteR = tableGLO(tableGLO.SatelliteID == infoGLO.PRN(k),:);

        for i = 1:infoGLO.nCodes

            %--- Obtain index when PRN is present
            satelliteR.Time.TimeZone = 'UTCLeapSeconds';
            [~, idx1] = intersect(dateTimeEpoch, satelliteR.Time);

            %--- Code-based raw pseudorange in (m)
            if any(append("C",infoGLO.codes(i,:)) == string(infoGLO.fields))
                satPseudorange(idx1,1) = satelliteR.(append("C",infoGLO.codes(i,:)));
            end

            %--- Carrier-phase range in (cycles) [with ambiguity!]
            if any(append("L",infoGLO.codes(i,:)) == string(infoGLO.fields))
                satCarrPhase(idx1,1) = satelliteR.(append("L",infoGLO.codes(i,:)));
            end
            
            %--- Doppler-shift in (Hz)
            if any(append("D",infoGLO.codes(i,:)) == string(infoGLO.fields))
                satDoppler(idx1,1) = satelliteR.(append("D",infoGLO.codes(i,:)));
            end

            %-- C/N0 in (dBHz)
            if any(append("S",infoGLO.codes(i,:)) == string(infoGLO.fields))
                satCN0(idx1,1) = satelliteR.(append("S",infoGLO.codes(i,:)));
            end
            
            %--- Store the data in the correspand row of the output
            dataGLONASS(infoGLO.nCodes*k+i-infoGLO.nCodes).Doppler = transpose(satDoppler);
            dataGLONASS(infoGLO.nCodes*k+i-infoGLO.nCodes).rawP = transpose(satPseudorange);
            dataGLONASS(infoGLO.nCodes*k+i-infoGLO.nCodes).CarrierPhase = transpose(satCarrPhase);
            dataGLONASS(infoGLO.nCodes*k+i-infoGLO.nCodes).cn0 = transpose(satCN0); 
        end

        clear satelliteR
        fprintf('%.2u ',infoGLO.PRN(k));
    end
    fprintf('\n');

    % Delete empty rows (SV has no data for a given signal)
    j = 0;
    for i = 1:(length(infoGLO.PRN)*infoGLO.nCodes)
        if  sum(~isnan(dataGLONASS(i-j).rawP)) == 0
            dataGLONASS(i-j) = [];
            j = j+1;
        end
    end
end

%----------------------------- Galileo ------------------------------------
fprintf('Parsing Galileo PRNs: ');
if infoGAL.flag == 1
    for k = 1:height(infoGAL.PRN)
        %--- Initialize time-series as NaN
        satPseudorange = NaN([height(dateTimeEpoch) 1]);
        satCarrPhase = NaN([height(dateTimeEpoch) 1]);
        satDoppler = NaN([height(dateTimeEpoch) 1]);
        satCN0 = NaN([height(dateTimeEpoch) 1]);

        %--- Now, we obtain the samples for each SV
        satelliteE = tableGAL(tableGAL.SatelliteID == infoGAL.PRN(k),:);

        for i = 1:infoGAL.nCodes

            %--- Obtain index when PRN is present
            satelliteE.Time.TimeZone = 'UTCLeapSeconds';
            [~, idx1] = intersect(dateTimeEpoch, satelliteE.Time);

            %--- Code-based raw pseudorange in (m) 
            if any(append("C",infoGAL.codes(i,:)) == string(infoGAL.fields))
                satPseudorange(idx1,1) = satelliteE.(append("C",infoGAL.codes(i,:)));
            end

            %--- Carrier-phase range in (cycles) [with ambiguity!]
            if any(append("L",infoGAL.codes(i,:)) == string(infoGAL.fields))
                satCarrPhase(idx1,1) = satelliteE.(append("L",infoGAL.codes(i,:)));
            end
            
            %--- Doppler-shift in (Hz)
            if any(append("D",infoGAL.codes(i,:)) == string(infoGAL.fields))
                satDoppler(idx1,1) = satelliteE.(append("D",infoGAL.codes(i,:)));
            end

            %--- C/N0 in (dBHz)
            if any(append("S",infoGAL.codes(i,:)) == string(infoGAL.fields))
                satCN0(idx1,1) = satelliteE.(append("S",infoGAL.codes(i,:)));
            end
            
            %--- Store the data in the correspand row of the output
            dataGalileo(infoGAL.nCodes*k+i-infoGAL.nCodes).Doppler = transpose(satDoppler);
            dataGalileo(infoGAL.nCodes*k+i-infoGAL.nCodes).rawP = transpose(satPseudorange);
            dataGalileo(infoGAL.nCodes*k+i-infoGAL.nCodes).CarrierPhase = transpose(satCarrPhase);
            dataGalileo(infoGAL.nCodes*k+i-infoGAL.nCodes).cn0 = transpose(satCN0);
        end

        clear satelliteE
        fprintf('%.2u ',infoGAL.PRN(k));
    end
    fprintf('\n');

    % Delete empty rows (SV has no data for a given signal)
    j = 0;
    for i = 1:(length(infoGAL.PRN)*infoGAL.nCodes)
        if  sum(~isnan(dataGalileo(i-j).rawP)) == 0
            dataGalileo(i-j) = [];
            j = j+1;
        end
    end
end

%----------------------------- BeiDou -------------------------------------
fprintf('Parsing BeiDou PRNs: ');
if infoBDS.flag == 1
    for k = 1:height(infoBDS.PRN)
        %--- Initialize time-series as NaN
        satPseudorange = NaN([height(dateTimeEpoch) 1]);
        satCarrPhase = NaN([height(dateTimeEpoch) 1]);
        satDoppler = NaN([height(dateTimeEpoch) 1]);

        satCN0 = NaN([height(dateTimeEpoch) 1]);

        %--- Now, we obtain the samples for each SV
        satelliteC = tableBEI(tableBEI.SatelliteID == infoBDS.PRN(k),:);
  
        for i = 1:infoBDS.nCodes

            %--- Obtain index when PRN is present
            satelliteC.Time.TimeZone = 'UTCLeapSeconds';
            [~, idx1] = intersect(dateTimeEpoch, satelliteC.Time);

            %--- Code-based raw pseudorange in (m)
            if any(append("C",infoBDS.codes(i,:)) == string(infoBDS.fields))
                satPseudorange(idx1,1) = satelliteC.(append("C",infoBDS.codes(i,:)));
            end

            %--- Carrier-phase range in (cycles) [with ambiguity!]
            if any(append("L",infoBDS.codes(i,:)) == string(infoBDS.fields))
                satCarrPhase(idx1,1) = satelliteC.(append("L",infoBDS.codes(i,:)));
            end
            
            %--- Doppler-shift in (Hz)
            if any(append("D",infoBDS.codes(i,:)) == string(infoBDS.fields))
                satDoppler(idx1,1) = satelliteC.(append("D",infoBDS.codes(i,:)));
            end

            %--- C/N0 in (dBHz)
            if any(append("S",infoBDS.codes(i,:)) == string(infoBDS.fields))
                satCN0(idx1,1) = satelliteC.(append("S",infoBDS.codes(i,:)));
            end
            
            %--- Store the data in the correspand row of the output
            dataBeiDou(infoBDS.nCodes*k+i-infoBDS.nCodes).Doppler = transpose(satDoppler);
            dataBeiDou(infoBDS.nCodes*k+i-infoBDS.nCodes).rawP = transpose(satPseudorange);
            dataBeiDou(infoBDS.nCodes*k+i-infoBDS.nCodes).CarrierPhase = transpose(satCarrPhase);
            dataBeiDou(infoBDS.nCodes*k+i-infoBDS.nCodes).cn0 = transpose(satCN0);
        end

        clear satelliteC
        fprintf('%.2u ',infoBDS.PRN(k));
    end
    fprintf('\n');

    % Delete empty rows (SV has no data for a given signal)
    j = 0;
    for i = 1:(length(infoBDS.PRN)*infoBDS.nCodes)
        if  sum(~isnan(dataBeiDou(i-j).rawP)) == 0
            dataBeiDou(i-j) = [];
            j = j+1;
        end
    end
end

%% Clear environment
clear idx1 idx2 i j k
clear satDoppler satPseudorange satCarrPhase satCN0
clear dateSecondsEpoch dateTimeEpoch

%% Finally, we join the tables in a unique table
obsSolutions = [dataGPS, dataGLONASS, dataGalileo, dataBeiDou];
fprintf('obsSolutions generated.\n');