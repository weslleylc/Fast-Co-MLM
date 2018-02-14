clc
clear all

%Exemplo de Parametros Básicos%
objParam.numberRepetitions=10;
objParam.normalization=0;
objParam.selectMethod=0;
objParam.paramLabel=[6];
objParam.paramPoints=[0.1:0.1:1];
objParam.dataName='default';
objParam.type='fsolve';
objParam.bias=0;
objParam.lambda=0;
objParam.validation=1;
objParam.permutationVector=[];




%Datasets % i
ParamLabel=[6];

Directory='uci-dataset/';
ListName={'g10n','car','wpbc','wdbc','german','sat','dbworld','heart','g50c','optdigits','uspst'};

Directory='Smartphone_Dataset/';
ListName={'climbingjumping','climbingrunning','descendingrunning','descendingstanding'};

for n=1:15,
    for label=ParamLabel,
        for Name=1:size(ListName,2), 
            n
            objParam.dataSet=load(strcat(Directory,char(ListName(Name))));
            objParam.dataSet=objParam.dataSet.dataset;
            objParam.numberRepetitionsForCotraining=n;
            objParam.dataName=char(ListName(Name));
            SelfNNMLM(objParam);
        end
    end
end


for i=1:15,
    for Name=1:size(ListName,2),
        results=load(strcat(char(ListName(Name)),'_SelfMLM_Online_results_',num2str(i),'_6.mat'));
        comp(i,Name)=mean(results.rates);
    end
end




% for Name=1:size(ListName,2),
%     ListName(Name)
%     st1=Tikz(Time(Name,:),'CoMLM');
%     st2=Tikz(Time2(Name,:),'FastCo-MLM');
%     char(strcat(st1,st2))
% end

