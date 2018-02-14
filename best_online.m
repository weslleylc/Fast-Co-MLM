function [bestIndex,badIndex,Classes] = best_online(R,n)
    %the first best per class
    [exemples,nRefPoints]=size(R.D{1}); 
    refPointsY=R.Ref{1}.y;
    [nExemples,nClasses]=size(refPointsY);
    j=1;
    Select=[];
    Classes=zeros(exemples,nClasses);
    Threshold=0.5;
    for i=1:exemples,
        Rate=R.Rate{1}+R.Rate{2};
        Rate_1=R.Rate{1}/Rate;
        Rate_2=R.Rate{2}/Rate;
        OutPut=R.D{1}(i,:)*Rate_1+R.D{2}(i,:)*Rate_2;
        
        [Max_Output IdMax_Output]=max(OutPut);
        [Max_Class IdClass]=max(refPointsY(IdMax_Output,:));
        Classes(i,IdClass)=1;

        if Max_Output>Threshold            
            Select(j,1)=Max_Output;        
            Select(j,2)=i;            
            Select(j,3)=IdClass;
            j=j+1;
        end
    end 
    if(isempty(Select)==1)
        bestIndex=[];
        badIndex=1:exemples;
    else
        [~,I] = sort(Select(:,1),'descend');
        Select=Select(I,:);
        [~,bestIndex_temp,~]=unique(Select(:,3));
        bestIndex=Select(bestIndex_temp,2);
        badIndex=1:exemples;
        badIndex(bestIndex)=[];
    end
end


% 
% function [bestIndex,badIndex,Classes] = best_online(R,n, refPoi)
%     %the first best per class
%     [exemples,nRefPoints]=size(R.D{1}); 
%     refPointsY=R.Ref{1}.y;
%     [nExemples,nClasses]=size(refPointsY);
%     j=1;
%     Select=[];
%     Classes=zeros(exemples,nClasses);
%     %Threshold=0;
%     for i=1:exemples,
%         Rate=R.Rate{1}+R.Rate{2};
%         Rate_1=R.Rate{1}/Rate;
%         Rate_2=R.Rate{2}/Rate;
% %         OutPut=R.D{1}(i,:)*Rate_1+R.D{2}(i,:)*Rate_2;
% 
% 
%         
%         [Max_Output IdMax_Output]=max(R.D{1}(i,:));
%         [Max_Output2 IdMax_Output2]=max(R.D{2}(i,:));
%         
%         [aux IdMax_1]=max(refPointsY(IdMax_Output,:));
%         [aux_Output2 IdMax_2]=max(refPointsY(IdMax_Output2,:));
% 
%         
%         
%         if (IdMax_1==IdMax_2)
%             Classes(i,IdMax_1)=1;
%             Select(j,1)=Max_Output+Max_Output2;        
%             Select(j,2)=i;            
%             Select(j,3)=IdMax_1;
%             j=j+1;
%         end
%     end 
%     if(isempty(Select)==1)
%         bestIndex=[];
%         badIndex=1:exemples;
%     else
%         [~,I] = sort(Select(:,1),'descend');
%         Select=Select(I,:);
%         [~,bestIndex_temp,~]=unique(Select(:,3));
%         bestIndex=Select(bestIndex_temp,2);
%         badIndex=1:exemples;
%         badIndex(bestIndex)=[];
%     end
% end
% 
% 
