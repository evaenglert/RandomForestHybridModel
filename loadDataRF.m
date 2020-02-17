function X = loadData(X)
% load the data of the analysis (create a struct array to store that)

% load the timespan of the analysis
[~,Date] = xlsread(X.Config.ExcelLoad.FileName,X.Config.ExcelLoad.WorkSheetName,X.Config.ExcelLoad.DateRange);
switch X.Config.ExcelLoad.LetterHead
    case 'Yes'
        X.RawData.Date = datenum(Date(2:end),X.Config.ExcelLoad.DateFormat); % converts date to Matlab format
        X.RawData.Date = flip(X.RawData.Date);
    case 'No'
        X.RawData.Date = datenum(Date(1:end),X.Config.ExcelLoad.DateFormat); % converts date to Matlab format
        X.RawData.Date = flip(X.RawData.Date);
end

% load the data for the analysis from the Excel Worksheet
Price = zeros(numel(X.RawData.Date),numel(X.Config.ExcelLoad.AssetList));
for i = 1:numel(X.Config.ExcelLoad.AssetList)
  X.RawData.Price(:,i) = xlsread(X.Config.ExcelLoad.FileName,X.Config.ExcelLoad.WorkSheetName,X.Config.ExcelLoad.AssetRange{i});
  X.RawData.Price(:,i) = flip(X.RawData.Price(:,i));
end

% define the asset names
X.RawData.Name = X.Config.ExcelLoad.AssetList; 

% select the weekdays for the analysis
switch X.Config.ExcelLoad.WhichDays
    case 'AllWeek'
    case 'NoWeekend'
        X.RawData.Price = X.RawData.Price(weekday(X.RawData.Date)>1 & weekday(X.RawData.Date)<7,:);
        X.RawData.Date = X.RawData.Date(weekday(X.RawData.Date)>1 & weekday(X.RawData.Date)<7);
    case 'JustMondays'
        X.RawData.Price = X.RawData.Price(weekday(X.RawData.Date) == 2,:);
        X.RawData.Date = X.RawData.Date(weekday(X.RawData.Date) == 2);
end

% save tha database
save 'StockReturns.mat' X

end

