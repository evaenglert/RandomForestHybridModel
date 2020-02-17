function X = plotDataSets(X)
tiledlayout(6,2);
myx = datetime(X.RawData.Date,'ConvertFrom','datenum');
for i=1:12
    nexttile
    name = X.RawData.Name(i);
    plot(myx, X.RawData.Price(:,i));
    ylim([0 400]);
    title(name);
end

end