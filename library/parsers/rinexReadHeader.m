function appendMetadata = rinexReadHeader(filename)
% Check that RINEX header metadata is present and add empty fields if
% necessary. Then append all fields for report inclusion
%
%   
% Written by Alex Minetto & Simone Zocca

obsMetadata = rinexinfo(filename);

if ~isfield(obsMetadata, 'FileName')
    obsMetadata.FileName = "";   
end

if ~isfield(obsMetadata, 'FileVersion')
    obsMetadata.FileVersion = "";
end

if ~isfield(obsMetadata, 'FileSatelliteSystem')
    obsMetadata.FileSatelliteSystem = "";
end

if ~isfield(obsMetadata, 'ObservationTypes') && isfield(obsMetadata.ObservationTypes, 'SatelliteSystem')
    obsMetadata.SatelliteSystem = [app.obsMetadata.ObservationTypes.SatelliteSystem];
else
    obsMetadata.SatelliteSystem = "";
end

if ~isfield(obsMetadata, 'PGM')
    obsMetadata.PGM = "";
end

if ~isfield(obsMetadata, 'RunBy')
    obsMetadata.RunBy = "";
end

if isfield(obsMetadata, 'CreationDate')
    obsMetadata.CreationDate = string(obsMetadata.CreationDate);
else
    obsMetadata.CreationDate = "";
end

if ~isfield(obsMetadata, 'RunBy')
    obsMetadata.RunBy = "";
end

if ~isfield(obsMetadata, 'MarkerName')
    obsMetadata.MarkerName = "";
end

if ~isfield(obsMetadata, 'MarkerNumber')
    obsMetadata.MarkerNumber = "";
end

if ~isfield(obsMetadata, 'MarkerType')
    obsMetadata.MarkerType = "";
end

if ~isfield(obsMetadata, 'Observer')
    obsMetadata.Observer = "";
end

if ~isfield(obsMetadata, 'Agency')
    obsMetadata.Agency = "";
end

if ~isfield(obsMetadata, 'ReceiverNumber')
    obsMetadata.ReceiverNumber = "";
end

if ~isfield(obsMetadata, 'ReceiverType')
    obsMetadata.ReceiverType = "";
end

if ~isfield(obsMetadata, 'ReceiverVersion')
    obsMetadata.ReceiverVersion = "";
end

if ~isfield(obsMetadata, 'AntennaNumber')
    obsMetadata.AntennaNumber = "";
end

if ~isfield(obsMetadata, 'AntennaType')
    obsMetadata.AntennaType = "";
end

if isfield(obsMetadata, 'AntennaDeltaHEN')
    obsMetadata.AntennaDeltaHEN = join(string(obsMetadata.AntennaDeltaHEN));
else
    obsMetadata.AntennaDeltaHEN = "";
end

if isfield(obsMetadata, 'ApproxPosition')
    obsMetadata.ApproxPosition = join(string(obsMetadata.ApproxPosition));
else
    obsMetadata.ApproxPosition = "";
end

if ~isfield(obsMetadata, 'Interval')
    obsMetadata.Interval = "";
end

%--- Fill metadata fields serially for report generation
appendMetadata = [obsMetadata.FileName, obsMetadata.FileVersion, obsMetadata.FileSatelliteSystem, obsMetadata.SatelliteSystem, ...
    obsMetadata.PGM, obsMetadata.RunBy, obsMetadata.CreationDate, obsMetadata.MarkerName, obsMetadata.MarkerNumber, "---", ...
    obsMetadata.Observer, obsMetadata.Agency, obsMetadata.ReceiverNumber, obsMetadata.ReceiverType, obsMetadata.ReceiverVersion, ...
    obsMetadata.AntennaNumber, obsMetadata.AntennaType, obsMetadata.AntennaDeltaHEN, obsMetadata.ApproxPosition, obsMetadata.Interval];