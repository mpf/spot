function varargout = cgs(A,b,varargin)
%CGS   Conjugate Gradients Squared Method.
%
%   X = cgs(A,B) attempts to solve the square linear system A*X=B via
%   the CGS method.
%
%   This routine is simply a wrapper to Matlab's own CGS routine,
%   and the argument list variations described in Matlab's CGS
%   documentation are also allowed here.  The usage is identical to
%   Matlab's default version, except that the first argument must be a
%   Spot operator.

%   Copyright 2009, Ewout van den Berg and Michael P. Friedlander
%   See the file COPYING.txt for full copyright information.
%   Use the command 'spot.gpl' to locate this file.

%   http://www.cs.ubc.ca/labs/scl/spot

% Check if A is square
if size(A,1) ~= size(A,2)
   error('Operator A must be square.');
end

% Set function handle
fun = @(x) A*x;

if nargout == 0
   cgs(fun,b,varargin{:});
elseif nargout <= 5
   varargout = cell(1,nargout);
   [varargout{:}] = cgs(fun,b,varargin{:});
else
   error('Too many output arguments.');
end
