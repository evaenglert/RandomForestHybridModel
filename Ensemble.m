% EXAMPLE: NONLINEAR REGRESSION (ensebmle methods)

%% define the main parameters of simulation

f = @(x) 2.5 + sin(x); % define DGP f(x)
noiseSTD = 1; % define the noise std
xMin = -5; xMax = 5; % define the range of the x axis
sampleSize = 1000; % define the sample size
trainsetRate = 0.75; % define the train set rate
randNStart = 491218380; % add the value for the setdemorandstream

hiddenLayerSize = 6; % hidden layer neurons
ensembleNumber = 50; % ensemble of neural networks

%% generate the noisy data set 

x = linspace(xMin, xMax, sampleSize); % define the x range
setdemorandstream(randNStart); % random seed is set to avoid this randomnes
y = f(x) + randn(size(x))*noiseSTD; % generate the noisy sample of the f(x)

%% train and plot the neural network

% add the figure parameters
visRange = [xMin, xMax];
figure
set(gcf,'Position',[100,100,960,520])

for j=1:ensembleNumber
    
    % add the input and target
    input = x;
    target = y;
    
    % add the NN parameters  
    net = fitnet(hiddenLayerSize);
    net.divideFcn = 'divideind';
    net.divideParam.trainInd = 1:sampleSize*trainsetRate;
    net.divideParam.valInd   = sampleSize*trainsetRate+1:sampleSize;
    net.trainFcn = 'trainlm';
    net.performFcn = 'mse';
     net.trainParam.showWindow = false;
     net.trainParam.showCommandLine = false;
    
    % random seed is set to avoid this randomnes
    setdemorandstream(randNStart+j)
 
    % train the NN
    [net,tr] = train(net,input,target);
    % forecast with NN
    output = net(input);
    
    % store the predicted values
    NNForecast(j,:)= output;
    EnsembleForecast(j,:) = sum(NNForecast(1:j,:),1)/j;
    rmseValidationNN(j,1)=sqrt(sum((NNForecast(j,:)-y).^2))/sampleSize*trainsetRate; % rmse on the validation set
    rmseValidationEnsemble(j,:)=sqrt(sum((EnsembleForecast(j,:)-y).^2))/sampleSize*trainsetRate; % rmse on the validation set
    
    clf, % clear the figure   
    % plot the DGP
    subplot(221); % create a subplot
    set(gca,'fontsize',14) % set the font size
    plot(x,f(x),'m','linewidth',2); hold on;
    xlim([visRange(1) visRange(2)]),ylim([visRange(1) visRange(2)]);
    scatter(x,y,'m'); % plot the noisy sample of the f(x)
    plot(x,NNForecast(j,:),'k','linewidth',2) % plot network output
    title(sprintf('Neural network %d',j)) % add title
    legend('f(x)','Targets', 'Network Output','Location','Southwest') % add a legend
    
    % plot the DGP
    subplot(223); hold on; % create a subplot
    set(gca,'fontsize',14) % set the font size
    plot(x,f(x),'m','linewidth',2); hold on;
    xlim([visRange(1) visRange(2)]),ylim([visRange(1) visRange(2)]);
    scatter(x,y,'m');  % plot the noisy sample of the f(x)
    plot(x, EnsembleForecast(j,:), 'k','linewidth', 2)  % plot the ensemble network output
    title(sprintf('Ensemble Neural network')) % add title
    legend('f(x)', 'Targets', 'Network Output','Location','Southwest') % add a legend
    
    % plot the error
    subplot(222); hold on % create a subplot
    set(gca,'fontsize',14) % set the font size
    plot(1:j,rmseValidationNN(1:j,1));
    xlabel('Different NNs')
    ylabel('Mean Squared Error')
    axis square; drawnow
    
    % plot the error
    subplot(224); hold on % create a subplot
    set(gca,'fontsize',14) % set the font size
    plot(1:j,rmseValidationEnsemble(1:j,1));
    xlabel('Numer of NNs')
    ylabel('Mean Squared Error')
    axis square; drawnow
    
    pause(0.1);
    
end


 
