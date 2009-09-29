function varargout = minres(A,b,varargin)
%MINRES   Minimum Residual Method.
%
%   X = minres(A,B) attempts to find a minimum-norm residual solution
%   X to the symmetric linear system A*X=B via the MINRES method.
%
%   This routine is simply a wrapper to Matlab's own MINRES routine,
%   and the argument list variations described in Matlab's MINRES
%   documentation are also allowed here.  The usage is identical to
%   Matlab's default version, except that the first argument must be a
%   Spot operator.

%   Copyright 2009, Ewout van den Berg and Michael P. Friedlander
%   See the file COPYING.txt for full copyright information.
%   Use the command 'spot.gpl' to locate this file.

%   http://www.cs.ubc.ca/labs/scl/spot

if (size(A,1) ~= size(A,2)) || norm(abs(A*b-A'*b),inf) > 1e-14*norm(b,inf)
   error('Operator A must be symmetric.');
end

% Set up multiplication function
fun = @(x) (A*x);

if nargout == 0
   minres(fun,b,varargin{:});
elseif nargout <= 6
   varargout = cell(1,nargout);
   [varargout{:}] = minres(fun,b,varargin{:});
else
   error('Too many output arguments.');
end
