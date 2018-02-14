function [ B,Pk ] = Multi_RLS_Online(Bo,Po,H,T)
    [l c]=size(Bo);
    B=zeros(l,c);
    [l2 c2]=size(H);
    Pk=Po-Po*H'*pinv(eye(l2)+H*Po*H')*H*Po;
    for i=1:l,
        B(:,i) = Bo(:,i)+Pk*H'*(T(:,i)-H*Bo(:,i));
    end
end


