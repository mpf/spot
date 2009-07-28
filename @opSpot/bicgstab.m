function varargout = bicgstab(A,b,varargin)
%BICGSTAB   BiConjugate Gradients Stabilized Method.
%
%   X = BICGSTAB(A,B), or any of the other variants allowed by
%   Matlab's own BICGSTAB routine.  The usage is identical to Matlab's
%   default version, except that the first argument must be a Spot
%   operator. (The remaining arguments are as usual.)

%   Copyright 2009, Ewout van den Berg and Michael P. Friedlander
%   http://www.cs.ubc.ca/labs/scl/sparco

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
