function TS =  ensembleTSForcasting(TS,Parameters)

armaTS =  armaTSForcastingRF(TS,Parameters.ARMA);
RandomForestTS =  RandomForestTSForcasting(TS,Parameters.RF);

TS.Date = armaTS.Date;
TS.OriginalValue = armaTS.OriginalValue;
TS.ForecastedValue = (armaTS.ForecastedValue + RandomForestTS.ForecastedValue)./2; 

                        
end