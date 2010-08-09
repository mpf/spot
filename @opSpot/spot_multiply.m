function y=spot_multiply(op,x,mode)
%This function determines the way to do multiplication. If 'op' extends
%'opSweep', it will call the classical multiply function. Else, it does a
%sequential multiplication successively calling 'multiply' on the columns
%of x. This function is called in 'mtimes' but can also be called from each 
%SPOT operator which needs to evaluate multiplication more directly.


%op.counter.plus1(mode);
%The previous line can be used to count the number of
%multiplications (mode1 & mode2) so as to compare
%algorithms.
if isa(op,'opSweep')
    y = op.multiply(x,mode);
else
    q=size(x,2);
    % Preallocate y
    if q > 1 || issparse(x)
        if mode==1
            y = zeros(op.m,q);
        else
            y = zeros(op.n,q);
        end
    end
    for i=1:q
        y(:,i) = op.multiply(x(:,i),mode);
    end
end
end