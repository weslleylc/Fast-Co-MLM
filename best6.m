function [bestIndex,badIndex] = best6(R,n)
    %the first best per class
    [exemples,classes]=size(R.D{1}); 
    [~, C]=size(R.D);  
    j=1;
    Select=[];
    Threshold=0;
    for i=1:exemples,         
        OutPut=R.D{1}(i,:)*R.Rate{1}+R.D{2}(i,:)*R.Rate{2};
        [Max3 Idmax3]=max(OutPut);
            
        if Max3>Threshold
            Select(j,1)=Max3;        
            Select(j,2)=i;            
            Select(j,3)=Idmax3;
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

