function varargout = cgls(A,b,varargin)
%CGLS Conjugate Gradients Least Squares
%
%   X = CGLS(A,B) attempts to solve the linear system A*X=B via the CGLS
%   method.
%
%   This routine is simply a wrapper to a custom CGLS routine, and the
%   argument list variations described in CGLS documentation are also
%   allowed here. The usage is identical to the default version, except
%   that the first argument must be a Spot operator.

fun = @(x, opt) afun(A, x, opt);

if nargout == 0
    cgls(fun, b, varargin{:});
elseif nargout <= 4
    varargout = cell(1,nargout);
    [varargout{:}] = cgls(fun,b,varargin{:});
else
    error('Too many output arguments.');
end

end


function y = afun(A, x, opt)

if opt == 1
    y = A*x;
elseif opt == 2
    y = A'*x;
end

end
