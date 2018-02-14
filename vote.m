function [bestIndex,badIndex] = vote( R ,votes )
    %all exemples for sumPi(X)>votes
    [exemples,classes]=size(R.D{1}); 
    [~, C]=size(R.D);  
    if isempty(votes)
        votes=round(C*0.7);
    end
    j=1;k=1;
    bestIndex=[];
    badIndex=[];
    for i=1:exemples,         
        M=zeros(1,classes);
        for c=1:C,            
            [Max Idmax]=max(R.D{c}(exemples,:));
            M(Idmax)=M(Idmax)+1;
        end
        [NumberOfVotes ~]=max(M);
        
        if NumberOfVotes>=votes
            bestIndex(j)=i;
            j=j+1;
        else
            badIndex(k)=i;
            k=k+1;
        end
    end
end

