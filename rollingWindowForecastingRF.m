function TS = rollingWindowForecasting(TS,model,bestmodel,Parameters)
% rolling window forecasting of the TS

WindowSize = Parameters.WindowSize;


for i = 1:(numel(TS.Date)-WindowSize) % number of forecasting
    
    % select the relevant subinterval of the time series
    TSsubint = TS.Value(i:i+WindowSize);

    switch char(model)
        case 'ARMA'
   
            BestModelfit = estimate(bestmodel.arima,TSsubint);
            ForecastedValue(i,1) = forecast(BestModelfit,1,'Y0',TSsubint);
            OriginalValue(i,1) = TS.Value(WindowSize+i);
            Date(i,1) = TS.Date(WindowSize+i);
               
        case 'RandomForest' 
            %fit the model 
            NumberOfTrees = Parameters.NumberOfTrees;
            Bootstrap = Parameters.Bootstrap;
            Lag = 4;
            NumPredictorstoSample = 4;
            
            Xmatrix = lagmatrix(TSsubint, [1,2,3,4]); %creating the covariate matrix
            Y = TSsubint(5:length(TSsubint));
            Xmatrix = Xmatrix(5:size(Xmatrix,1), :); %deleting first 4 rows of matrix
            
         
            BestModelfit = TreeBagger(NumberOfTrees, Xmatrix, Y, ...
            'Method', 'regression');
            
            
            ForecastedValue(i,1) = predict(BestModelfit, transpose(TSsubint((length(TSsubint)-3): length(TSsubint)))) ;
            OriginalValue(i,1) = TS.Value(WindowSize+i);
            Date(i,1) = TS.Date(WindowSize+i);
    end
    
    clear TSsubint
end

TS.ForecastedValue = ForecastedValue;
TS.OriginalValue = OriginalValue;
TS.Date = Date;

end