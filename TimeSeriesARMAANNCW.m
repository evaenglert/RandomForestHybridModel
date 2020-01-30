%% define the model
clc
clear all
model = arima('Constant',0.5,'AR',{0.7,0.25},'Variance',.1);
NOfPeriods=100;
rng('default')
Y = simulate(model,NOfPeriods);

ForecastedDays=20;
pMax = 4;

%% estimate the optimal AR model
Data = Y(1:NOfPeriods-ForecastedDays);
LogL = zeros(pMax,1);
AIC = zeros(pMax,1);
for p = 1:pMax
        model = arima('ARLags',[1:p]);
        [~,~,LogL(p)] = estimate(model,Data);
        AIC(p)=-2*LogL(p)+2*(p+1);
end
minAIC = min(AIC);
bestP = find(AIC == minAIC);
bestmodel=arima('ARLags',[1:bestP]);
%% forecast with the model
for i=1:ForecastedDays    
clear Data;
Data = Y(1:NOfPeriods-ForecastedDays-1+i);

Bestfit = estimate(bestmodel,Data);
Ypred = forecast(Bestfit,1,'Y0',Data);

OriginalData(i,1)=Y(NOfPeriods-ForecastedDays+i); 
ForecastedData(i,1)=Ypred; 
i
end
mseARMA=sum((OriginalData-ForecastedData).^2)/ForecastedDays;

%%
neuron=[5 6 7 8 9];     %ez a param�ter adja meg hogy a rejtett r�tegben l�v� neuronok sz�m�t
repeatN = 10;    %mivel az �leken a s�lyok random m�don ad�dnak az optimali�zl�s eset�n ezzel a param�terrel tudjuk be�ll�tani, hogy h�nyszor futtatjuk le a h�l�zatot (�tlagol�ssal kapjuk majd meg a h�l�zat eredm�nyess�g�t)
Y2 = windowize(Y((5-pMax):80),1:(pMax+1)); %minden egyes nap el��ll�tjuk a k�leltett �rt�keket  amennyi sz�ks�ges a training sethez

for i=1:pMax
    for j=1:numel(neuron)
        for k=1:repeatN
            
            TrainSet = 1:71-pMax; %tanul� halmaz
            ValidationSet = 71-pMax:80-pMax; %valid�ci�s halmaz
            
            [TrainInput,ps] = mapminmax(Y2(:,(pMax-i+1):pMax)'); %0-1 tartom�nyra transzform�ljuk a training set input adatokat
            [TrainTarget,ts] = mapminmax(Y2(:,pMax+1)'); %0-1 tartom�nyra transzform�ljuk a training set target adatokat
            
            inputs = TrainInput; %inputk�nt megadjuk a transzform�lt adatokat
            targets = TrainTarget; %targetk�nt megadjuk a transzform�lt adatokat
            
            setdemorandstream(491218380+k) %be�ll�tjuk a randomsz�m gener�tort hogy k�s�bb vissza tudjuk n�zni az eredm�nyeket
            hiddenLayerSize = neuron(j);  %megadjuk a rejett r�tegben l�v� neuronok sz�m�t
            net = fitnet(hiddenLayerSize);
            
            net.divideFcn = 'divideind'; %felosztjuk az adatokat tanul� �s valid�k� r�szre
            net.divideParam.trainInd = TrainSet;  %tanul� r�sz
            net.divideParam.valInd   = ValidationSet; %valid�l� r�sz
            net.inputs{1}.processFcns = {}; %be�ll�tjuk hogy m�r ne transzform�lja a h�l�zat az adatainkat hiszen mi m�r megtett�k
            net.outputs{2}.processFcns = {}; %be�ll�tjuk hogy m�r ne transzform�lja a h�l�zat az adatainkat hiszen mi m�r megtett�k
            net.trainFcn = 'trainlm';   %a Levengerg-Marquardt tanul� algoritmust haszn�ljuk
            net.performFcn = 'mse';   %mse alapj�n optimaliz�l az algoritmus
            
            [net,tr] = train(net,inputs,targets); %lefuttatjuk a h�l�zatot
            outputs = net(inputs); %el�rejelz�nk a h�l�zattal
            
            DataValidationNN((i-1)*numel(neuron)*repeatN+(j-1)*repeatN+k,:)=mapminmax('reverse',outputs(1,ValidationSet),ts); %elmentj�k a m�r visszatranszform�lt outputadatokat
            
        end
        DataMeanValidationNN((i-1)*numel(neuron)+j,:)=mean(DataValidationNN(((i-1)*numel(neuron)*repeatN+(j-1)*repeatN+1):((i-1)*numel(neuron)*repeatN+j*repeatN),:)); %�tlagoljuk az egyes eredm�nyeket amelyek azonos rejtett r�tegben l�v� neuronsz�mhoz kapcsol�dnak
        rmseValidationNN((i-1)*numel(neuron)+j,1)=sum((Y2(ValidationSet,end)'-DataMeanValidationNN((i-1)*numel(neuron)+j,:)).^2)/numel(ValidationSet); %rmse a valid�ci�s halmazon
    end
end
z=sort(rmseValidationNN); %sorbarakjuk az rmse �rt�keket
optimalpar=find(rmseValidationNN==z(1,1));   %kiv�lsztjuk melyikhez tartozik a legkisebb rmse, ez lesz az optim�lis h�l�zat
optimalLag=(optimalpar-mod(optimalpar,numel(neuron)))/numel(neuron);
if mod(optimalpar,numel(neuron))==0
    optimalNeuron=neuron(end);
else
    optimalNeuron=neuron(mod(optimalpar,numel(neuron)));
end
clear Y2
%%
for i=1:ForecastedDays
    
    Y2 = windowize(Y((5-optimalLag):(80-1+i)),1:(optimalLag+1)); %minden egyes nap el��ll�tjuk a k�leltett �rt�keket amennyi sz�ks�ges a training sethez  
    YT = Y2(size(Y2,1)-optimalLag+1:end,end);
    
    TrainSet = 1:size(Y2,1)-10; %tanul� halmaz
    ValidationSet = size(Y2,1)-9:size(Y2,1); %valid�ci�s halmaz
        
    [TrainInput,ps] = mapminmax(Y2(:,1:optimalLag)'); %0-1 tartom�nyra transzform�ljuk a training set input adatokat
    [TrainTarget,ts] = mapminmax(Y2(:,optimalLag+1)'); %0-1 tartom�nyra transzform�ljuk a training set target adatokat
    
    TestInput = mapminmax('apply',YT,ps); % [0,1] tartom�nyra transzform�ljuk az adatokat
    
    for k=1:repeatN

        inputs = TrainInput; %inputk�nt megadjuk a transzform�lt adatokat
        targets = TrainTarget; %targetk�nt megadjuk a transzform�lt adatokat
        
        setdemorandstream(491218380+k) %be�ll�tjuk a randomsz�m gener�tort hogy k�s�bb vissza tudjuk n�zni az eredm�nyeket
        hiddenLayerSize = optimalNeuron;  %megadjuk a rejett r�tegben l�v� neuronok sz�m�t
        net = fitnet(hiddenLayerSize);
        
        net.divideFcn = 'divideind'; %felosztjuk az adatokat tanul� �s valid�k� r�szre
        net.divideParam.trainInd = TrainSet;  %tanul� r�sz
        net.divideParam.valInd   = ValidationSet; %valid�l� r�sz
        net.inputs{1}.processFcns = {}; %be�ll�tjuk hogy m�r ne transzform�lja a h�l�zat az adatainkat hiszen mi m�r megtett�k
        net.outputs{2}.processFcns = {}; %be�ll�tjuk hogy m�r ne transzform�lja a h�l�zat az adatainkat hiszen mi m�r megtett�k
        net.trainFcn = 'trainlm';   %a Levengerg-Marquardt tanul� algoritmust haszn�ljuk
        net.performFcn = 'mse';   %mse alapj�n optimaliz�l az algoritmus
        
        [net,tr] = train(net,inputs,targets); %lefuttatjuk a h�l�zatot
        outputs = net(inputs); %el�rejelz�nk a h�l�zattal
        outputs2 = net(TestInput); %el�rejelz�nk a h�l�zattal
        DataFNN(k,:)=mapminmax('reverse',outputs2,ts); %elmentj�k a m�r visszatranszform�lt outputadatokat 
    end
    OriginalData(i,1)=Y(NOfPeriods-ForecastedDays+i);
    ForecastedDataNN(i,1)=mean(DataFNN(1:repeatN,:)); 

end

rmseNN=sqrt(sum(OriginalData-ForecastedDataNN).^2)/ForecastedDays;
[~,p_value]=Perform_CW_test(OriginalData,ForecastedData,ForecastedDataNN);