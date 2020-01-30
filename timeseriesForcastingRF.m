function X =  timeseriesForcasting(X)
% forecasting the selected TS

% select the analysis timespan
X.ForecastData.Price = X.RawData.Price(X.RawData.Date>=datenum(X.Config.Forecasting.Analysis.StartDate) & X.RawData.Date <= datenum(X.Config.Forecasting.Analysis.EndDate),:);
X.ForecastData.Date = X.RawData.Date(X.RawData.Date>=datenum(X.Config.Forecasting.Analysis.StartDate) & X.RawData.Date <= datenum(X.Config.Forecasting.Analysis.EndDate));

% select the relevant time series
X.ForecastData.Price = X.ForecastData.Price(:,X.Config.Forecasting.Analysis.Assets);
       
% calculate the logreturn TS of the analysis
X.ForecastData.Price = cellfunwrapper('@(x) diff(log(x))',X.ForecastData.Price);
X.ForecastData.Date = X.ForecastData.Date(2:end); % lagged date becasuse we calculate the logreturns

% forecast with ARMA model
TS.Value = X.ForecastData.Price;
TS.Date = X.ForecastData.Date;
TS =  armaTSForcastingRF(TS,X.Config.Forecasting.Model.ARMA);

% save the result of the causality analysis to the X struct
X.ForecastData.Arma.ForecastedValue = TS.ForecastedValue;
X.ForecastData.Arma.OriginalValue = TS.OriginalValue;
X.ForecastData.Arma.Date = TS.Date;

% forecast with RandomForest model
TS.Value = X.ForecastData.Price;
TS.Date = X.ForecastData.Date;
TS =  RandomForestTSForcasting(TS,X.Config.Forecasting.Model.RF);

%save the result of the casuality analysis to the X struct
X.ForecastData.RF.ForecastedValue = TS.ForecastedValue;
X.ForecastData.RF.OriginalValue = TS.OriginalValue;
X.ForecastData.RF.Date = TS.Date;

% forecast with hybrid model
TS.Value = X.ForecastData.Price;
TS.Date = X.ForecastData.Date;
TS =  hybridTSForcasting(TS,X.Config.Forecasting.Model);

%save the result of the casuality analysis to the X struct
X.ForecastData.Hybrid.ForecastedValue = TS.ForecastedValue;
X.ForecastData.Hybrid.OriginalValue = TS.OriginalValue;
X.ForecastData.Hybrid.Date = TS.Date;

% forecast with ensemble model
TS.Value = X.ForecastData.Price;
TS.Date = X.ForecastData.Date;
TS =  ensembleTSForcasting(TS,X.Config.Forecasting.Model);

%save the result of the casuality analysis to the X struct
X.ForecastData.Ensemble.ForecastedValue = TS.ForecastedValue;
X.ForecastData.Ensemble.OriginalValue = TS.OriginalValue;
X.ForecastData.Ensemble.Date = TS.Date;

end