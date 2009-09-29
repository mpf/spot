function varargout = bicgstab(A,b,varargin)
%BICGSTAB   BiConjugate Gradients Stabilized Method.
%
%   X = bicgstab(A,B) attempts to solve the linear system A*X=B via
%   the BICGSTAB method.
%
%   This routine is simply a wrapper to Matlab's own BICGSTAB routine,
%   and the argument list variations described in Matlab's BICGSTAB
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
   bicgstab(fun,b,varargin{:});
elseif nargout <= 5
   varargout = cell(1,nargout);
   [varargout{:}] = bicgstab(fun,b,varargin{:});
else
   error('Too many output arguments.');
end
