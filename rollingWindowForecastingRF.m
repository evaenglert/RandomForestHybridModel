function TS = rollingWindowForecasting(TS,model,bestmodel,Parameters)
% rolling window forecasting of the TS

WindowSize = Parameters.WindowSize;


for i = 1:(numel(TS.Date)-WindowSize) % number of forecasting
    
    % select the relevant subinterval of the time series
    TSsubint = TS.Value(i:i+WindowSize-1);

    switch char(model)
        case 'ARMA'
   
            BestModelfit = estimate(bestmodel.arima,TSsubint);
            ForecastedValue(i,1) = forecast(BestModelfit,1,'Y0',TSsubint);
            OriginalValue(i,1) = TS.Value(WindowSize+i);
            Date(i,1) = TS.Date(WindowSize+i);
               
        case 'RandomForest' 
            %fit the model 
            NumberOfTrees = Parameters.NumberOfTrees;
            Lag = Parameters.Lag;
            numPredictorstoSample = 2;
            
            Xmatrix = lagmatrix(TSsubint, 1:Lag); %creating the covariate matrix
            Y = TSsubint((Lag+1):length(TSsubint));
            Xmatrix = Xmatrix((Lag+1):size(Xmatrix,1), :); %deleting first 4 rows of matrix
            
         
            BestModelfit = TreeBagger(NumberOfTrees, Xmatrix, Y, ...
            'Method', 'regression', 'NumPredictorsToSample', numPredictorstoSample);
            
            
            ForecastedValue(i,1) = predict(BestModelfit, flip(transpose(TSsubint((length(TSsubint)-Lag+1): length(TSsubint))))) ;
            OriginalValue(i,1) = TS.Value(WindowSize+i);
            Date(i,1) = TS.Date(WindowSize+i);
            
        case 'Hybrid'
            %running ARIMA first on TSsubint
            BestModelfit = estimate(bestmodel.arima,TSsubint);
            ArimaForecastedValue(i,1) = forecast(BestModelfit,1,'Y0',TSsubint);
            OriginalValue(i,1) = TS.Value(WindowSize+i);
            Date(i,1) = TS.Date(WindowSize+i);
            
            %getting the residuals out of ARIMA fit
            [residuals,~] = infer(BestModelfit, TSsubint);
            
            %
            Lag = 4;
            Xmatrix = lagmatrix(residuals, 1:Lag); %creating the covariate matrix
            Y = residuals(Lag+1:length(residuals));
            Xmatrix = Xmatrix((Lag+1):size(Xmatrix,1), :); %deleting first 'lag' rows of matrix
            
         
            BestModelfitRF = TreeBagger(100, Xmatrix, Y, ...
            'Method', 'regression', 'NumPredictorsToSample', 2);
                        
            RFForecastedValue(i,1) = predict(BestModelfitRF, flip(transpose(residuals((length(residuals)-Lag+1): length(residuals))))) ;

            ForecastedValue(i,1) = RFForecastedValue(i,1) + ArimaForecastedValue(i,1);
            
            
    end
    
    clear TSsubint
end

TS.ForecastedValue = ForecastedValue;
TS.OriginalValue = OriginalValue;
TS.Date = Date;

end