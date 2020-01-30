function TS =  hybridTSForcasting(TS,Parameters)
%running ARIMA model first
arimaTS =  armaTSForcastingRF(TS,Parameters.ARMA);

%calculating error terms of ARIMA predictions
ErrorTS.Value = arimaTS.OriginalValue - arimaTS.ForecastedValue;
ErrorTS.Date = arimaTS.Date;

%running RandomForest on error terms
ErrorTS = RandomForestTSForcasting(ErrorTS,Parameters.RF);

%shortening down arima so that dimensions match
arimaTS.ForecastedValue = arimaTS.ForecastedValue((length(arimaTS.ForecastedValue) - ...
    length(ErrorTS.ForecastedValue)+1):length(arimaTS.ForecastedValue));

TS.ForecastedValue = ErrorTS.ForecastedValue + arimaTS.ForecastedValue;
TS.OriginalValue = arimaTS.OriginalValue((length(arimaTS.ForecastedValue) - ...
    length(ErrorTS.ForecastedValue)+1):length(arimaTS.ForecastedValue));

TS.Date = ErrorTS.Date;
                        
end