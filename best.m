function [bestIndex badIndex] = best(R,Nao_usado)
    %all exemples for F1(x)==F2(x)
    D1=R.D{1};
    D2=R.D{2};
    [linD1 colD1]=size(D1);
    j=1;k=1;
    bestIndex=[];
    badIndex=[];
    alpha=0.5;
    for i=1:linD1,
        [Max Idmax]=max(D1(i,:));
        [Max2 Idmax2]=max(D2(i,:));

        if Idmax==Idmax2
            if (Max>=alpha) &&  (Max2>=alpha)
                bestIndex(j)=i;
                j=j+1;
            else
                badIndex(k)=i;
                k=k+1;
            end
        else
            badIndex(k)=i;
            k=k+1;
        end
    end

end

