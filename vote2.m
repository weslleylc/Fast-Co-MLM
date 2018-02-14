function [bestIndex,badIndex] = vote2( R,type)
    %the first best per class
    [exemples,classes]=size(R.D{1}); 
    [~, C]=size(R.D);  
    j=1;k=1;
    for i=1:exemples,         
        M=zeros(1,classes);
        value=zeros(1,classes);
        for c=1:C,            
            [Max Idmax]=max(R.D{c}(exemples,:));
            M(Idmax)=M(Idmax)+1;
            value(Idmax)=value(Idmax)+Max;
        end
        [Votes indexC]=max(M);        
        NumberOfVotes(i,1)=Votes; 
        NumberOfVotes(i,2)=value(Idmax);
        NumberOfVotes(i,3)=indexC;        
        NumberOfVotes(i,4)=i;
    end
    if type~=1        
        [~,I] = sort(NumberOfVotes(:,1),'descend');
    else
        [~,I] = sort(NumberOfVotes(:,2),'descend');
    end
    NumberOfVotes=NumberOfVotes(I,:);
    
    [~, Temp_bestIndex, ~] = unique(NumberOfVotes(:,3));
    bestIndex=NumberOfVotes(Temp_bestIndex,4);
    badIndex=1:exemples;
    badIndex(bestIndex)=[];
end

