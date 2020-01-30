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
neuron=[5 6 7 8 9];     %ez a paraméter adja meg hogy a rejtett rétegben lévõ neuronok számát
repeatN = 10;    %mivel az éleken a súlyok random módon adódnak az optimaliázlás esetén ezzel a paraméterrel tudjuk beállítani, hogy hányszor futtatjuk le a hálózatot (átlagolással kapjuk majd meg a hálózat eredményességét)
Y2 = windowize(Y((5-pMax):80),1:(pMax+1)); %minden egyes nap elõállítjuk a kéleltett értékeket  amennyi szükséges a training sethez

for i=1:pMax
    for j=1:numel(neuron)
        for k=1:repeatN
            
            TrainSet = 1:71-pMax; %tanuló halmaz
            ValidationSet = 71-pMax:80-pMax; %validációs halmaz
            
            [TrainInput,ps] = mapminmax(Y2(:,(pMax-i+1):pMax)'); %0-1 tartományra transzformáljuk a training set input adatokat
            [TrainTarget,ts] = mapminmax(Y2(:,pMax+1)'); %0-1 tartományra transzformáljuk a training set target adatokat
            
            inputs = TrainInput; %inputként megadjuk a transzformált adatokat
            targets = TrainTarget; %targetként megadjuk a transzformált adatokat
            
            setdemorandstream(491218380+k) %beállítjuk a randomszám generátort hogy késõbb vissza tudjuk nézni az eredményeket
            hiddenLayerSize = neuron(j);  %megadjuk a rejett rétegben lévõ neuronok számát
            net = fitnet(hiddenLayerSize);
            
            net.divideFcn = 'divideind'; %felosztjuk az adatokat tanuló és validákó részre
            net.divideParam.trainInd = TrainSet;  %tanuló rész
            net.divideParam.valInd   = ValidationSet; %validáló rész
            net.inputs{1}.processFcns = {}; %beállítjuk hogy már ne transzformálja a hálózat az adatainkat hiszen mi már megtettük
            net.outputs{2}.processFcns = {}; %beállítjuk hogy már ne transzformálja a hálózat az adatainkat hiszen mi már megtettük
            net.trainFcn = 'trainlm';   %a Levengerg-Marquardt tanuló algoritmust használjuk
            net.performFcn = 'mse';   %mse alapján optimalizál az algoritmus
            
            [net,tr] = train(net,inputs,targets); %lefuttatjuk a hálózatot
            outputs = net(inputs); %elõrejelzünk a hálózattal
            
            DataValidationNN((i-1)*numel(neuron)*repeatN+(j-1)*repeatN+k,:)=mapminmax('reverse',outputs(1,ValidationSet),ts); %elmentjük a már visszatranszformált outputadatokat
            
        end
        DataMeanValidationNN((i-1)*numel(neuron)+j,:)=mean(DataValidationNN(((i-1)*numel(neuron)*repeatN+(j-1)*repeatN+1):((i-1)*numel(neuron)*repeatN+j*repeatN),:)); %átlagoljuk az egyes eredményeket amelyek azonos rejtett rétegben lévõ neuronszámhoz kapcsolódnak
        rmseValidationNN((i-1)*numel(neuron)+j,1)=sum((Y2(ValidationSet,end)'-DataMeanValidationNN((i-1)*numel(neuron)+j,:)).^2)/numel(ValidationSet); %rmse a validációs halmazon
    end
end
z=sort(rmseValidationNN); %sorbarakjuk az rmse értékeket
optimalpar=find(rmseValidationNN==z(1,1));   %kiválsztjuk melyikhez tartozik a legkisebb rmse, ez lesz az optimális hálózat
optimalLag=(optimalpar-mod(optimalpar,numel(neuron)))/numel(neuron);
if mod(optimalpar,numel(neuron))==0
    optimalNeuron=neuron(end);
else
    optimalNeuron=neuron(mod(optimalpar,numel(neuron)));
end
clear Y2
%%
for i=1:ForecastedDays
    
    Y2 = windowize(Y((5-optimalLag):(80-1+i)),1:(optimalLag+1)); %minden egyes nap elõállítjuk a kéleltett értékeket amennyi szükséges a training sethez  
    YT = Y2(size(Y2,1)-optimalLag+1:end,end);
    
    TrainSet = 1:size(Y2,1)-10; %tanuló halmaz
    ValidationSet = size(Y2,1)-9:size(Y2,1); %validációs halmaz
        
    [TrainInput,ps] = mapminmax(Y2(:,1:optimalLag)'); %0-1 tartományra transzformáljuk a training set input adatokat
    [TrainTarget,ts] = mapminmax(Y2(:,optimalLag+1)'); %0-1 tartományra transzformáljuk a training set target adatokat
    
    TestInput = mapminmax('apply',YT,ps); % [0,1] tartományra transzformáljuk az adatokat
    
    for k=1:repeatN

        inputs = TrainInput; %inputként megadjuk a transzformált adatokat
        targets = TrainTarget; %targetként megadjuk a transzformált adatokat
        
        setdemorandstream(491218380+k) %beállítjuk a randomszám generátort hogy késõbb vissza tudjuk nézni az eredményeket
        hiddenLayerSize = optimalNeuron;  %megadjuk a rejett rétegben lévõ neuronok számát
        net = fitnet(hiddenLayerSize);
        
        net.divideFcn = 'divideind'; %felosztjuk az adatokat tanuló és validákó részre
        net.divideParam.trainInd = TrainSet;  %tanuló rész
        net.divideParam.valInd   = ValidationSet; %validáló rész
        net.inputs{1}.processFcns = {}; %beállítjuk hogy már ne transzformálja a hálózat az adatainkat hiszen mi már megtettük
        net.outputs{2}.processFcns = {}; %beállítjuk hogy már ne transzformálja a hálózat az adatainkat hiszen mi már megtettük
        net.trainFcn = 'trainlm';   %a Levengerg-Marquardt tanuló algoritmust használjuk
        net.performFcn = 'mse';   %mse alapján optimalizál az algoritmus
        
        [net,tr] = train(net,inputs,targets); %lefuttatjuk a hálózatot
        outputs = net(inputs); %elõrejelzünk a hálózattal
        outputs2 = net(TestInput); %elõrejelzünk a hálózattal
        DataFNN(k,:)=mapminmax('reverse',outputs2,ts); %elmentjük a már visszatranszformált outputadatokat 
    end
    OriginalData(i,1)=Y(NOfPeriods-ForecastedDays+i);
    ForecastedDataNN(i,1)=mean(DataFNN(1:repeatN,:)); 

end

rmseNN=sqrt(sum(OriginalData-ForecastedDataNN).^2)/ForecastedDays;
[~,p_value]=Perform_CW_test(OriginalData,ForecastedData,ForecastedDataNN);