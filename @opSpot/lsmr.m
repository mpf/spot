function varargout = lsmr(A,b,varargin)
%LSMR Iterative solver for least-squares problems.
%
%   X = LSMR(A,B) solves the system of linear equations A*X = B.
%
%   This routine is simply a wrapper to a custom LSMR routine, and the
%   argument list variations described in LSMR documentation are also
%   allowed here. The usage is identical to the default version, except
%   that the first argument must be a Spot operator.

fun = @(x, opt) afun(A, x, opt);

if nargout == 0
    lsmr(fun, b, varargin{:});
elseif nargout <= 8
    varargout = cell(1,nargout);
    [varargout{:}] = lsmr(fun,b,varargin{:});
else
    error('Too many output arguments');
end

end


function y = afun(A, x, opt)

if opt == 1
    y = A*x;
elseif opt == 2
    y = A'*x;
end

end