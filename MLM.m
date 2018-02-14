clc
clear all

%Datasets % i
ParamLabel=[6];
ListName={'g10n','car','wpbc','wdbc','german','sat','dbworld','heart','g50c','optdigits','uspst'};
ListName={'ucfphone_view1','ucfphone_view2'};
ListName={'climbingdescending','climbingjumping','climbingrunning','climbingstanding','climbingwalking','descendingjumping','descendingrunning','descendingstanding','descendingwalking','jumpingrunning','jumpingstanding','jumpingwalking','runningstanding','runningwalking','standingwalking'};
ListName={'climbingjumping','climbingrunning','descendingrunning','descendingstanding'};
Directory='uci-dataset/';
Directory='Smartphone_Dataset/';
for n=1:15,
    for label=ParamLabel,
        for Name=1:size(ListName,2),
            Std_Co_training_MLM(10,n,0,1,label,Directory,char(ListName(Name)));
    %       Std_MLM(10,0,1,label,Directory,char(ListName(Name)));
        end
    end
end


% comp=[];
% for Name=1:size(ListName,2),
%     results = load(strcat(strcat(char(ListName(Name)),'_MLM_results_6'),'.mat'));
%     comp(Name,1)=mean(results.rates);
%     results = load(strcat(strcat(char(ListName(Name)),'_CoMLM_results_6'),'.mat'));
%     comp(Name,2)=mean(results.rates);
%     if(comp(Name,2)>comp(Name,1))
%         comp(Name,3)=1;
%     else
%         comp(Name,4)=0;
%     end
% end


comp=zeros(size(ListName,2),15);
comp2=zeros(size(ListName,2),15);
for n=1:15,
    for Name=1:size(ListName,2),
        s1=strcat(num2str(n),'_');
        s2=strcat(strcat(char(ListName(Name)),'_CoMLM_MV2_results_'));
        results = load(strcat(strcat(s2,s1),'6.mat'));
        comp(Name,n)=mean(results.rates);
        results = load(strcat(strcat(char(ListName(Name)),'_MLM_results_6'),'.mat'));
        comp2(Name,:)=repmat(mean(results.rates),1,15);
    end
end

colors={'-dk';'-sg';'-ob'; '-vc';'-*r'};
%Melhores [2,3,7,8];
for Name=1:size(ListName,2),
    h=figure; 
    hold on
    plot(comp(Name,:),colors{2});  
    plot(comp2(Name,:),colors{5});  
    xlim([1 15])
    set(gca,'XTick',1:15);
    %set font size
    set(gca,'fontsize',18)
    %set the precision
    yt=get(gca,'YTick');
    ylab=num2str(yt(:), '%0.2f');
    set(gca,'YTickLabel',ylab);
    legend('CoMLM','MLM','Location','best');
    ylabel('Average accuracy'); % x-axis label
    xlabel('Iterations') % y-axis label
    savepdf( h, char(ListName(Name)));
    hold off
end

% Data=[]
% ListName={'car','g10n','wpbc','wdbc','german','sat','dbworld','heart','g50c','optdigits','uspst'};
% for Name=1:size(ListName,2),
%     DataName=char(ListName(Name));
%     Directory='uci-dataset/';
%     dataset = load(strcat(strcat(Directory,DataName),'.mat'));
%     dataset=dataset.dataset;
%     [Nexp,Natt]=size([dataset.xtrain{1};dataset.xval{1};dataset.xtest{1}]);
%     labels = unique(dataset.ytrain{1});
%     Data(Name,1)=Nexp;
%     Data(Name,2)=Natt;
%     Data(Name,3)=length(labels);
% end


% for Name=1:size(ListName,2),
%     results = load(strcat(strcat(char(ListName(Name)),'_MLM_results_2'),'.mat'));
%     results2 = load(strcat(strcat(char(ListName(Name)),'_CoMLM_results_test2'),'.mat'));    
%     results3 = load(strcat(strcat(char(ListName(Name)),'_EnMLM_results_2'),'.mat'));
%     Data1 = load(strcat('C:/Users/Weslley/workspace/Cotraining/',strcat(strcat('CoForest_',char(ListName(Name))),'_2_.txt')));
%     results4.rates=1-Data1(:,2);
%     Data2 = load(strcat('C:/Users/Weslley/workspace/Cotraining/',strcat(strcat('TriTrain_',char(ListName(Name))),'_2_.txt')));
%     results5.rates=1-Data2(:,2);
%     results6 = load(strcat(strcat(char(ListName(Name)),'_CoKnn_results_2'),'.mat'));
%     
%     [~,indmax] = max(results.rates);
%     [~,indmin] = min(results.rates);
%     results.rates([indmax indmin])=[]; 
%     comp(Name,1)=mean(results.rates);
%     
%     [~,indmax] = max(results2.rates);
%     [~,indmin] = min(results2.rates);
%     results2.rates([indmax indmin])=[];
%     comp(Name,2)=mean(results2.rates); 
%     
%     [~,indmax] = max(results3.rates);
%     [~,indmin] = min(results3.rates);
%     results3.rates([indmax indmin])=[];    
%     comp(Name,3)=mean(results3.rates);
%     
%     [~,indmax] = max(results4.rates);
%     [~,indmin] = min(results4.rates);
%     results4.rates([indmax indmin])=[];    
%     comp(Name,4)=mean(results4.rates);
%     
%     [~,indmax] = max(results5.rates);
%     [~,indmin] = min(results5.rates);
%     results5.rates([indmax indmin])=[];    
%     comp(Name,5)=mean(results5.rates);
%     
% %     [~,indmax] = max(results6.rates);
% %     [~,indmin] = min(results6.rates);
% %     results6.rates([indmax indmin])=[];    
%     comp(Name,6)=mean(results6.rates);
%     
%     [~,indmax] = max(comp(Name,1:6));
%     comp(Name,7)=indmax;
% 
%     
% end