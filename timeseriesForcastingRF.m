function X =  timeseriesForcasting(X)
% forecasting the selected TS

% select the analysis timespan
X.ForecastData.Price = X.RawData.Price(X.RawData.Date>=datenum(X.Config.Forecasting.Analysis.StartDate) & X.RawData.Date <= datenum(X.Config.Forecasting.Analysis.EndDate),:);
X.ForecastData.Date = X.RawData.Date(X.RawData.Date>=datenum(X.Config.Forecasting.Analysis.StartDate) & X.RawData.Date <= datenum(X.Config.Forecasting.Analysis.EndDate));

%results for different stocks will be saved here
X.Results.Arma = cell(1,length(X.Config.Forecasting.Analysis.Assets));
X.Results.RF = cell(1,length(X.Config.Forecasting.Analysis.Assets));
X.Results.Hybrid = cell(1,length(X.Config.Forecasting.Analysis.Assets));
X.Results.Original = cell(1,length(X.Config.Forecasting.Analysis.Assets));

X.ForecastData.Price = X.ForecastData.Price(:,X.Config.Forecasting.Analysis.Assets);


for i=1:length(X.Config.Forecasting.Analysis.Assets)
    % select the relevant time series
    Price = X.ForecastData.Price(:,i);

    % calculate the logreturn TS of the analysis
    Price = cellfunwrapper('@(x) diff(log(x))',Price);    
    Date = X.ForecastData.Date(2:end); % lagged date becasuse we calculate the logreturns

    % forecast with ARMA model
    TS.Value = Price;
    TS.Date = Date;
    TS =  armaTSForcastingRF(TS,X.Config.Forecasting.Model.ARMA);

    % save the result of the causality analysis to the X struct
    X.Results.Arma{i} = TS.ForecastedValue;
    X.Results.Original{i} = TS.OriginalValue;


    % forecast with RandomForest model
    TS.Value = Price;
    TS.Date = Date;
    TS =  RandomForestTSForcasting(TS,X.Config.Forecasting.Model.RF);
    
    % save the result of the causality analysis to the X struct
    X.Results.RF{i} = TS.ForecastedValue;

    % forecast with hybrid model
    TS.Value = Price;
    TS.Date = Date;
    TS =  hybridTSForcasting(TS,X.Config.Forecasting.Model.ARMA);
    
    % save the result of the causality analysis to the X struct
    X.Results.Hybrid{i} = TS.ForecastedValue;

    % forecast with ensemble model
    TS.Value = Price;
    TS.Date = Date;
    X.ForecastData.Ensemble.Date = TS.Date;     
    X.Results.Ensemble{i} = (X.Results.RF{i} + X.Results.Arma{i})./2;
    
    
    X.Results.Date = Date;
    
    clear Price;
end





end
