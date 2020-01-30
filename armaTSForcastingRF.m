function TS =  armaTSForcastingRF(TS,Parameters)
% forecasting the selected TS with ARMA model

% optimal model
bestmodel =  optimalModelRF(TS,Parameters.WindowSize,Parameters.Lag,Parameters.InfCriteria);

% rolling window forecasting with the optimal model
TS = rollingWindowForecastingRF(TS,'ARMA',bestmodel,Parameters);

end