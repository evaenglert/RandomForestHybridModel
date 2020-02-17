function X = plotCumSum(X)

myx = datetime(X.Results.Date(51:length(X.Results.Date)),'ConvertFrom','datenum');
for i=1:length(X.Config.Forecasting.Analysis.Assets)
    nexttile
    name = X.RawData.Name(i);
    plot(myx, X.Evaluate.ARMA.cumsum{i}, 'b', myx, X.Evaluate.RF.cumsum{i}, 'g', myx, X.Evaluate.Hybrid.cumsum{i}, ...
        'r', myx, X.Evaluate.Ensemble.cumsum{i});
    title(name);
    legend({'Arma', 'RF', 'Hybrid', 'Ensemble'},'Location','northwest','Orientation','horizontal')
end

end