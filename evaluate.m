function X = evaluate(X)
%evaluating the results from casuality analysis
X.Evaluate.ARMA.MAE = cell(1,length(X.Config.Forecasting.Analysis.Assets));
X.Evaluate.ARMA.MAD = cell(1,length(X.Config.Forecasting.Analysis.Assets));
X.Evaluate.ARMA.MAD  = cell(1,length(X.Config.Forecasting.Analysis.Assets));
X.Evaluate.ARMA.RMSE  = cell(1,length(X.Config.Forecasting.Analysis.Assets));
X.Evaluate.ARMA.cumsum  = cell(1,length(X.Config.Forecasting.Analysis.Assets));

X.Evaluate.RF.MAE  = cell(1,length(X.Config.Forecasting.Analysis.Assets));
X.Evaluate.RF.MAD  = cell(1,length(X.Config.Forecasting.Analysis.Assets));
X.Evaluate.RF.RMSE  = cell(1,length(X.Config.Forecasting.Analysis.Assets));
X.Evaluate.RF.cumsum  = cell(1,length(X.Config.Forecasting.Analysis.Assets));

X.Evaluate.Hybrid.MAE  = cell(1,length(X.Config.Forecasting.Analysis.Assets));
X.Evaluate.Hybrid.MAD  = cell(1,length(X.Config.Forecasting.Analysis.Assets));
X.Evaluate.Hybrid.RMSE = cell(1,length(X.Config.Forecasting.Analysis.Assets));
X.Evaluate.Hybrid.cumsum = cell(1,length(X.Config.Forecasting.Analysis.Assets));

X.Evaluate.Ensembe.MAE = cell(1,length(X.Config.Forecasting.Analysis.Assets));
X.Evaluate.Ensembe.MAD = cell(1,length(X.Config.Forecasting.Analysis.Assets));
X.Evaluate.Ensembe.RMSE = cell(1,length(X.Config.Forecasting.Analysis.Assets));
X.Evaluate.Ensembe.cumsum = cell(1,length(X.Config.Forecasting.Analysis.Assets));

for i=1:length(X.Config.Forecasting.Analysis.Assets)
    ARMAerrors = X.Results.Arma{i} - X.Results.Original{i};

    X.Evaluate.ARMA.MAE{i} = mae(ARMAerrors);
    X.Evaluate.ARMA.MAD{i}= mad(ARMAerrors);
    X.Evaluate.ARMA.RMSE{i} = sqrt(mean((ARMAerrors).^2));
    X.Evaluate.ARMA.cumsum{i} = cumsum(abs(ARMAerrors));

    RFerrors = X.Results.RF{i} - X.Results.Original{i};

    X.Evaluate.RF.MAE{i} = mae(RFerrors);
    X.Evaluate.RF.MAD{i} = mad(RFerrors);
    X.Evaluate.RF.RMSE{i} = sqrt(mean((RFerrors).^2));
    X.Evaluate.RF.cumsum{i} = cumsum(abs(RFerrors));

    Hybriderrors = X.Results.Hybrid{i} - X.Results.Original{i};

    X.Evaluate.Hybrid.MAE{i} = mae(Hybriderrors);
    X.Evaluate.Hybrid.MAD{i} = mad(Hybriderrors);
    X.Evaluate.Hybrid.RMSE{i} = sqrt(mean((Hybriderrors).^2));
    X.Evaluate.Hybrid.cumsum{i} = cumsum(abs(Hybriderrors));

    Ensembleerrors = X.Results.Ensemble{i} - X.Results.Original{i};

    X.Evaluate.Ensemble.MAE{i} = mae(Ensembleerrors);
    X.Evaluate.Ensemble.MAD{i} = mad(Ensembleerrors);
    X.Evaluate.Ensemble.RMSE{i} = sqrt(mean((Ensembleerrors).^2));
    X.Evaluate.Ensemble.cumsum{i} = cumsum(abs(Ensembleerrors));

    end

end
