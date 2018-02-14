function [model] =  train_MLM(refPoints, learnPoints, bias, lambda)

%% Validate the user input
model=[];
if nargin<1
    disp('Error: no arguments.');
    return
end

% Check data
if isempty(refPoints)
    % Data is empty
    disp('Error: reference points set is empty.')
    return
else
    if (~isstruct(refPoints))
        disp('Error: data set is not a struct; should be of form refPoints.x and refPoints.y.')
        return
    else
        fields = isfield(refPoints,{'x','y'});
        if (fields(1) ~= 1 || fields(2) ~= 1)
            disp('Error: data set does not have refPoints.x and refPoints.y fields.')
            return
        else
            refX=refPoints.x;
            refY=refPoints.y;
            [n,d]=size(refX);
            [no,do]=size(refY);
            if (n~=no) || (n<2)
                disp('Error: refPoints.x and refPoints.y do not have the same number of samples or too few samples.');
                return
            end
        end
    end
end

trX = [];
trY = [];
if(exist('learnPoints', 'var') && ~isempty(learnPoints)),
    if(isstruct(learnPoints)),
        fields = isfield(learnPoints,{'x','y'});
        if (fields(1) == 1 && fields(2) == 1),
            if(size(learnPoints.x, 1) ~= size(learnPoints.y, 1))
                disp('Error: inconsistent dimensions in the learning points.')
                return
            else
                trX = learnPoints.x;
                trY = learnPoints.y; 
            end
        else
            disp('Error: Wrong struct! Missing learnPoints.x or learnPoints.y')
            return
        end
    else
        disp('Error: Learning points variable should be a struct.')
        return
    end   
end

if (~exist('bias', 'var') || isempty(bias)),
    bias = 0; % Default bias.
end

if (~exist('lambda', 'var') || isempty(lambda)),
    lambda = 0; % Default regularization factor.
end


%% Points used for the distance-based regression
if (isempty(trX) == 0),
    Dx = pdist2(trX, refX);
    Dy = pdist2(trY, refY);
end

if(bias ~= 0),
    Dx = [ones(size(Dx, 1), 1) Dx(:,1:n)];
    n = n+1;
end

%% Set the model
if(lambda ~= 0 )
    model.B = pinv(Dx'*Dx + lambda.*eye(n))*Dx'*Dy; 
else
    model.B =  pinv(Dx)*Dy;
end
model.refX = refX;
model.refY = refY;
model.bias = bias;