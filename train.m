%Exemplo de Parametros Básicos%
objParam.numberRepetitions=10;
objParam.numberRepetitionsForCotraining=5;
objParam.normalization=0;
objParam.selectMethod=0;
objParam.paramLabel=[6];
objParam.paramPoints=[0.5:0.1:1];
objParam.dataSet=load('Smartphone_Dataset/descendingrunning.mat');
objParam.dataSet=objParam.dataSet.dataset;
objParam.dataName='default';
objParam.type='fsolve';
objParam.bias=0;
objParam.lambda=0;
objParam.validation=1;
objParam.permutationVector=1:3000;

%Exemplo de chamada de treinamento e teste
[FullMODEL]=FastCoMLM(objParam);

%Exemplo de chamada somento do treino%
[MODEL]=TrainFastCoMLM(objParam);

%Exemplo de chamada somento do teste%

%Matriz de coeficientes do primeiro modelo gerado
finalBeta=MODEL{1}.finalBeta;
finalrefPoints=MODEL{1}.finalrefPoints;
testData.x=objParam.dataSet.xtest{1};
testData.y=S_encoding(objParam.dataSet.ytest{1});

%Função teste do método NN-MLM
[~,Yh]=test_nnMLM(finalBeta,testData,finalrefPoints); 

%Comparação do modelo B*X vs B´*X 
for j = 1: length(testData.y),
    [~, index(j)] = max(Yh(j,:));
    [~, target(j)] = max(testData.y(j, :));
end  
%Taxa de acerto
rate = length(find(index == target))/length(testData.y)




