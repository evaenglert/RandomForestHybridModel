function X = evaluate(X)
%evaluating the results from casuality analysis
lengthOfHybrid = length(X.ForecastData.Hybrid.ForecastedValue);
lengthOfARMA = length(X.ForecastData.Arma.ForecastedValue);
lengthOfRF = length(X.ForecastData.RF.ForecastedValue);
lengthOfEnsemble = length(X.ForecastData.Ensemble.ForecastedValue);

ARMAerrors = X.ForecastData.Arma.ForecastedValue((lengthOfARMA- lengthOfHybrid +1): lengthOfARMA) - ...
    X.ForecastData.Arma.OriginalValue((lengthOfARMA- lengthOfHybrid +1): lengthOfARMA);

X.Evaluate.ARMA.MAE = mae(ARMAerrors);
X.Evaluate.ARMA.MAD = mad(ARMAerrors);
X.Evaluate.ARMA.RMSE = sqrt(mean((ARMAerrors).^2));

RFerrors = X.ForecastData.RF.ForecastedValue((lengthOfRF- lengthOfHybrid +1): lengthOfRF) - ...
    X.ForecastData.RF.OriginalValue((lengthOfRF- lengthOfHybrid +1): lengthOfRF);

X.Evaluate.RF.MAE = mae(RFerrors);
X.Evaluate.RF.MAD = mad(RFerrors);
X.Evaluate.RF.RMSE = sqrt(mean((RFerrors).^2));

X.Evaluate.Hybrid.MAE = mae(X.ForecastData.Hybrid.ForecastedValue - X.ForecastData.Hybrid.OriginalValue);
X.Evaluate.Hybrid.MAD = mad(X.ForecastData.Hybrid.ForecastedValue - X.ForecastData.Hybrid.OriginalValue);
X.Evaluate.Hybrid.RMSE = sqrt(mean((X.ForecastData.Hybrid.ForecastedValue - X.ForecastData.Hybrid.OriginalValue).^2));

Ensembleerrors = X.ForecastData.Ensemble.ForecastedValue((lengthOfEnsemble- lengthOfHybrid +1): lengthOfEnsemble) - ...
    X.ForecastData.Ensemble.OriginalValue((lengthOfEnsemble- lengthOfHybrid +1): lengthOfEnsemble);

X.Evaluate.Ensemble.MAE = mae(Ensembleerrors);
X.Evaluate.Ensemble.MAD = mad(Ensembleerrors);
X.Evaluate.Ensemble.RMSE = sqrt(mean((Ensembleerrors).^2));


end
