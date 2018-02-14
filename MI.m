function [ M ] = MI( X,Y )
%MI Summary of this function goes here
%   Detailed explanation goes here
    [lin col]=size(X);
    zeros(col,1);
    for i=1:col,
        M(i)=mutInfo(X(:,i),Y);
    end
end

