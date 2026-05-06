function [msg, T1] = CompareCNo(acqRes, varargin)
%This function generates the CN0 plot

if ~isempty(varargin)
    figureName = varargin{1};
else
    figureName = 999;
end

%--- Create Table 
IQSCn0Array = acqRes.peakMetric.*(acqRes.carrFreq~=-inf);
IQSCn0Array(IQSCn0Array==0) = NaN;
PRN = 1:numel(IQSCn0Array);

T1 = table(PRN',IQSCn0Array',acqRes.carrFreq');
idCanc = [];
for idx = 1:numel(IQSCn0Array)
    %--- If both TLM and IQS empty, delete row for visualization
    if isnan(T1{idx,2})
        idCanc(end+1) = idx;
    end
end
T1(idCanc,:) = [];
T1.Properties.VariableNames = {'PRN','IQS C/No','IQS Dop. Shift'};

h = figure(figureName);
uitable('Data',T1{:,:},'ColumnName',T1.Properties.VariableNames,'RowName',T1.Properties.RowNames,'Units', 'Normalized', 'Position',[0, 0, 1, 1]);
  
%--- Plot location
Pix_SS = get(0,'screensize');
if figureName == 312
    h.OuterPosition = [Pix_SS(3)/2 0 Pix_SS(3)/4 Pix_SS(4)/3];
elseif figureName == 314
    h.OuterPosition = [3*Pix_SS(3)/4 0 Pix_SS(3)/4 Pix_SS(4)/3];
end

msg = "C/N0 comparative table generated";
