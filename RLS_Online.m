function [ B,Pk ] = RLS_Online(Bo,Po,H,T)
    [l c]=size(H);
    Pk=Po-Po*H'*pinv(eye(l)+H*Po*H')*H*Po;
    B=Bo+Pk*H'*(T-H*Bo);
    

%     lambda=1;
% 
%     g=(1/lambda)*Po*H'/(1+lambda*H*Po*H');
%     B=Bo+g*(T-H*Bo);
%     Pk=(1/lambda)*(Po-g*H*Po');

    
end

