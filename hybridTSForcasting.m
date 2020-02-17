function TS =  hybridTSForcasting(TS,Parameters)
bestmodel = optimalModelRF(TS,Parameters.WindowSize,Parameters.Lag,Parameters.InfCriteria);
TS = rollingWindowForecastingRF(TS,'Hybrid',bestmodel,Parameters);


                        
end