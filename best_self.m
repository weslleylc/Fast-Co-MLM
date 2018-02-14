function [bestIndex,badIndex,Classes] = best_self(R,n)
    %the first best per class
    [exemples,nRefPoints]=size(R.D);
    refPointsY=R.Ref.y;
    [nExemples,nClasses]=size(refPointsY);
    j=1;
    Select=[];
    Classes=zeros(exemples,nClasses);
    Threshold=0.5;
    for i=1:exemples,
        [Max_Output IdMax_Output]=max(R.D(i,:));
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
