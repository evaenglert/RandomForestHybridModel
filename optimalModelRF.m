function bestmodel =  optimalModelRF(TS,WindowSize,Lag,InfCriteria)
% select the optimal model

TS = TS.Value(1:WindowSize);
LogL = zeros(numel(Lag),1);
AIC = zeros(numel(Lag),1);
for i = 1:numel(Lag)
    model = arima('ARLags',[1:Lag(i)]);
    [~,~,LogL(i)] = estimate(model,TS);
    switch char(InfCriteria)
        case 'AIC'
            AIC(i)=-2*LogL(i)+2*(Lag(i)+1);
    end
end
minAIC = min(AIC);
bestP = find(AIC == minAIC);
bestmodel.arima = arima('ARLags',[1:Lag(bestP)]);

end