function [Yh, error] =  test_MLM(model, data, method)

DX = pdist2(data.x, model.refX);
if(model.bias == 1),
    DX = [ones(size(data.x, 1), 1) DX];
end
DYh = DX*model.B; % Estimates for the output distances

% Options for the optimization methods
options_fsolve = optimset('Display', 'off', 'Algorithm','levenberg-marquardt', 'FunValCheck', 'on', 'TolFun', 10e-6 );
options_lsq = optimoptions('lsqnonlin','Algorithm','levenberg-marquardt', 'Jacobian','on', 'FunValCheck', 'on', 'Display', 'off' );

Yh = zeros(size(data.x, 1), size(model.refY, 2));
yh0 = mean(model.refY); % initial estimate for y

if(strcmpi(method, 'lsqnonlin'))   
    for i = 1: size(data.x, 1),   
        Yh(i, :) = lsqnonlin(@(x)(fun(x, model.refY, DYh(i, :))), yh0, [], [], options_lsq);
    end
else
    for i = 1: size(data.x, 1),
        Yh(i, :) = fsolve(@(x)(sum((model.refY - repmat(x, length(model.refY), 1)).^2, 2) - DYh(i,:)'.^2), yh0, options_fsolve);
    end
end

error = [];
if(isempty(data.y) == 0)
    error = data.y - Yh;
end

