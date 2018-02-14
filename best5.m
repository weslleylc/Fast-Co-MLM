function [bestIndex,badIndex] = best5(R,n)
    %the first best per class
    [exemples,classes]=size(R.D{1}); 
    [~, C]=size(R.D);  
    j=1;
    Select=[];
    for i=1:exemples,         
        [Max Idmax]=max(R.D{1}(i,:));
        [Max2 Idmax2]=max(R.D{2}(i,:));
        
        if Idmax==Idmax2
%             OutPut=R.D{1}(i,:)*R.Rate{1}+R.D{2}(i,:)*R.Rate{2};
%             [Max3 Idmax3]=max(OutPut);
            Select(j,1)=Max*R.Rate{1}+Max2*R.Rate{2};        
            Select(j,2)=i;            
            Select(j,3)=Idmax;
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

