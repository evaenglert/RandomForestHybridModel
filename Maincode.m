clc
clear all

%% read the data from BankData.xlx

X = defineExcelParametersRF; 
X = loadDataRF(X); 

%% run a hybrid time series forecasting model

X = defineTSForcastingParametersRF(X); % define the parameters of the time series forecasting 
X = timeseriesForcastingRF(X); % forecasting the selected TS 
%% evaluate results

X = evaluate(X);
X = plotCumSum(X);





