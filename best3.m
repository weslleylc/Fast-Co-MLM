function [bestIndex,badIndex] = best3(R,n)
    %the first best per class
    [exemples,classes]=size(R.D{1}); 
    [~, C]=size(R.D);  
    j=1;
    Select=[];
    for i=1:exemples,         
        [Max Idmax]=max(R.D{1}(i,:));
        [Max2 Idmax2]=max(R.D{2}(i,:));
        if Idmax==Idmax2                
            Select(j,1)=Max+Max2;        
            Select(j,2)=i;
            j=j+1;
        end
    end   
    if(isempty(Select)==1)
        bestIndex=[];
        badIndex=1:exemples;
    else
        [~,I] = sort(Select(:,1),'descend');    
        Select=Select(I,:);
        if(n>size(Select,1))
            bestIndex=Select(:,2);
            badIndex=1:exemples;
            badIndex(bestIndex)=[];
        else
            bestIndex=Select(1:n,2);
            badIndex=1:exemples;
            badIndex(bestIndex)=[];
        end
    end
end

