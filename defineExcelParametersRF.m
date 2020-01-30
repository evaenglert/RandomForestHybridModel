function X = defineExcelParameters(X)
% define the Excel parameters for the data loading (create a struct array to store that)

X.Config.ExcelLoad.FileName = 'StockReturns.xlsx'; % define the file name
X.Config.ExcelLoad.WorkSheetName = 'Munka1'; % define the worksheet name
X.Config.ExcelLoad.LetterHead = 'Yes'; % define is it lettehead or no

X.Config.ExcelLoad.DateRange = 'B:B'; % define the range of the date
X.Config.ExcelLoad.DateFormat = 'yyyy.mm.dd'; % define the date format (in Excel)


X.Config.ExcelLoad.AssetList = {'AAPL','AXP','BA','C','CSCO','F','GE','INTC', 'KO', 'NKE', 'T', 'WMT'}; % define the asset list
X.Config.ExcelLoad.AssetRange = {'C:C','D:D','E:E','F:F','G:G','H:H','I:I', 'J:J', 'K:K', 'L:L', 'M:M', 'N:N'}; % define the range of the assets
X.Config.ExcelLoad.Weekend = 'No'; % select the weekend or no

end