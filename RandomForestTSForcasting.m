function TS =  RandomForestTSForcasting(TS,Parameters)
% forecasting the selected TS with Random Forest model

% optimal model
%bestmodel =  optimalModelRF(TS,Parameters.WindowSize,Parameters.Lag,Parameters.InfCriteria);
%bestmodel.RandomForest = ... 

% rolling window forecasting with the optimal model
bestmodel = [];
TS = rollingWindowForecastingRF(TS,'RandomForest',bestmodel,Parameters);
                        
end