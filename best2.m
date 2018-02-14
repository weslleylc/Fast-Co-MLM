function [bestIndex,badIndex] = best2(R ,Nex)
    %the Nex first best exemples per class for each classifier
    [exemples,classes]=size(R.D{1});   

    S=struct('classifier','');
    %for each instance on unlabeled data
    for c=1:2,    
        for i=1:exemples, 
            [Max,Idmax]=max(R.D{c}(i,:));%instance i 
            S.classifier{c}(i,1)=Max;%value of classifier confidence
            S.classifier{c}(i,2)=Idmax;%class number
            S.classifier{c}(i,3)=i;%instance number
        end
    end
    %order the exemples per classifier confidence
    [~,I] = sort(S.classifier{1}(:,1),'descend');
    S.classifier{1}=S.classifier{1}(I,:);
    [~,I] = sort(S.classifier{2}(:,1),'descend');    
    S.classifier{2}=S.classifier{2}(I,:);
    BestIndexLoop=[];
    %for each Nex
    for i=1:Nex,
        %for each view
        for c=1:2,
            %select 1 class exemple more confident
            [~, Temp_bestIndex, ~] = unique(S.classifier{c}(:,2));
            if isempty(BestIndexLoop)
                BestIndexLoop=S.classifier{c}(Temp_bestIndex,3);
            else
                BestIndexLoop=[BestIndexLoop ;S.classifier{c}(Temp_bestIndex,3)];
            end              
            S.classifier{c}(Temp_bestIndex,:)=[];
        end
    end
    [bestIndex,~,~]=unique(BestIndexLoop);
    badIndex=1:exemples;
    badIndex(bestIndex)=[];
end

