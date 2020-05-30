function [estimates, model] = CircleFitCart(x, y, r0, x0, dx)
    % Initial guess
%     start_point = [c1; c2];
    start_point = [r0; x0; dx];
%     start_point = [r0; x0];

    model=@Circle;
    % increase the maximum number of iteratiion.
    nparam = length(start_point);
    imax = 500;
    imaxfeval = 500;
    opts = optimset('MaxFunEvals', imaxfeval*nparam, 'MaxIter', imax*nparam);
    estimates = fminsearch(model, start_point);

    function [rmse, FittedCurve] = Circle(params)
        a = params(1);  % r
        b = params(2);  % x0
        c = params(3);  % dx
        
%         idx1=find(x<x0);
%         idx2=find(x>=x0);
%         
        FittedCurve = sqrt(a^2-(c*(x-b)).^2);
        ErrorVector = FittedCurve - y;
        rmse = sqrt(sum(ErrorVector .^ 2)/length(FittedCurve));
    end
end


