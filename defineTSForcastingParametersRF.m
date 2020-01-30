function X = defineTSForcastingParametersRF(X)
% define the parameters of the time series forecasting

% the analysis parameters
X.Config.Forecasting.Analysis.ModelType = {'Hybrid','RF','ARMA','Ensemble'}; % the model type
X.Config.Forecasting.Analysis.Type = {'Individual'}; % the analysis type
switch char(X.Config.Forecasting.Analysis.Type)
    case 'Individual'
        X.Config.Forecasting.Analysis.Assets = 1; % the selected assets
    case 'Assetclass'
        X.Config.Forecasting.Analysis.Assets = 1:numel(X.Config.ExcelLoad.AssetList); % the selected assets
end
X.Config.Forecasting.Analysis.StartDate = {'2004-12-10'}; % startdate
X.Config.Forecasting.Analysis.EndDate = {'2020-01-13'}; % enddate
X.Config.Forecasting.Analysis.WindowSize = 250; % the windowsize 
X.Config.Forecasting.Analysis.WindowType = {'Rollig'}; % the windowtype

% the model parameters
% ARMA
X.Config.Forecasting.Model.ARMA.WindowSize = X.Config.Forecasting.Analysis.WindowSize;
X.Config.Forecasting.Model.ARMA.WindowType = X.Config.Forecasting.Analysis.WindowType;
X.Config.Forecasting.Model.ARMA.OptimParameters = {'Lag'}; % the parameters which we optimize
X.Config.Forecasting.Model.ARMA.Lag = 1:4; % possible lag parameters
X.Config.Forecasting.Model.ARMA.InfCriteria = {'AIC'}; % the information criteria

% RF
X.Config.Forecasting.Model.RF.WindowSize = X.Config.Forecasting.Analysis.WindowSize;
X.Config.Forecasting.Model.RF.WindowType = X.Config.Forecasting.Analysis.WindowType;
X.Config.Forecasting.Model.RF.NumberOfTrees = 100; % number of weak learners
X.Config.Forecasting.Model.RF.Lag = 1:4; % possible lag parameters
X.Config.Forecasting.Model.RF.TrainSetRate = 0.75; % the train set rate
X.Config.Forecasting.Model.RF.Bootstrap = 'Replacement'; 
X.Config.Forecasting.Model.RF.RandNStart = 491218380; % the value for the setdemorandstream

% the model update parameters
X.Config.Forecasting.Model.Update.RF.Weights = {'Always'};
X.Config.Forecasting.Model.Update.RF.Architecture = {'Once'};
X.Config.Forecasting.Model.Update.ARMA.Weights = {'Always'};
X.Config.Forecasting.Model.Update.ARMA.Architecture = {'Once'};

% asserts for the parameters
assert(X.Config.Forecasting.Analysis.WindowSize>=100,'Window size is too small')

end