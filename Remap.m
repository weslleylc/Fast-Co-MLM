function [ Dx,Dy ] = Remap(refPoints,data )
    Dx = pdist2(data.x, refPoints.x);
    Dy = pdist2(data.y, refPoints.y);
end

