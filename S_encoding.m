function [ vector ] = S_encoding( input )
    [l c]=size(input);
    vector=zeros(l,max(input));
    for i=1:l,
        vector(i,input(i))=1;
    end
end

