function varargout = pcg(A,b,varargin)
%PCG   Preconditioned Conjugate Gradients Method.
%
%   See help of PCG function provided by Matlab.

%   Copyright 2009, Ewout van den Berg and Michael P. Friedlander
%   http://www.cs.ubc.ca/labs/scl/sparco
%   $Id$

if (size(A,1) ~= size(A,2)) || norm(abs(A*b-A'*b),inf) > 1e-14*norm(b,inf)
   error('Operator A must be symmetric positive definite.');
end

% Set up multiplication function
fun = @(x) (A*x);

if nargout == 0
   pcg(fun,b,varargin{:});
elseif nargout <= 5
   varargout = cell(1,nargout);
   [varargout{:}] = pcg(fun,b,varargin{:});
else
   error('Too many output arguments.');
end
