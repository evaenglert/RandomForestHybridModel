function X = loadData(X)
% load the data of the analysis (create a struct array to store that)

% load the timespan of the analysis
[~,Date] = xlsread(X.Config.ExcelLoad.FileName,X.Config.ExcelLoad.WorkSheetName,X.Config.ExcelLoad.DateRange);
switch X.Config.ExcelLoad.LetterHead
    case 'Yes'
        X.RawData.Date = datenum(Date(2:end),X.Config.ExcelLoad.DateFormat); % converts date to Matlab format
    case 'No'
        X.RawData.Date = datenum(Date(1:end),X.Config.ExcelLoad.DateFormat); % converts date to Matlab format
end

% load the data for the analysis from the Excel Worksheet
Price = zeros(numel(X.RawData.Date),numel(X.Config.ExcelLoad.AssetList));
for i = 1:numel(X.Config.ExcelLoad.AssetList)
  X.RawData.Price(:,i) = xlsread(X.Config.ExcelLoad.FileName,X.Config.ExcelLoad.WorkSheetName,X.Config.ExcelLoad.AssetRange{i});
end

% define the asset names
X.RawData.Name = X.Config.ExcelLoad.AssetList; 

% select the weekdays for the analysis
switch X.Config.ExcelLoad.Weekend
    case 'Yes'
    case 'No'
        X.RawData.Price = X.RawData.Price(weekday(X.RawData.Date)>1 & weekday(X.RawData.Date)<7,:);
        X.RawData.Date = X.RawData.Date(weekday(X.RawData.Date)>1 & weekday(X.RawData.Date)<7);
end

% save tha database
save 'StockReturns.mat' X

end

