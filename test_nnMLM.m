function [p, output] = test_nnMLM( B, Data ,refPoints)
    Dx = pdist2(Data.x, refPoints.x); 
    Dy=Dx*B;
    [l c]=size(Dy);
    [l2 n]=size(refPoints.y);
    p=zeros(l,c);
    output=zeros(l,n);
%     p=1./Dy;
    for i=1:l,
        s=sum(1./Dy(i,:));
        for j=1:c,
            p(i,j)=(1/Dy(i,j))/s;
        end        
        [v index]=max(p(i,:));
        output(i,:)=refPoints.y(index,:);
    end
end

