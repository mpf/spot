function varargout = bicg(A,b,varargin)
%BICG   BiConjugate Gradients Method.
%
%   See help of BICG function provided by Matlab.

%   Copyright 2009, Ewout van den Berg and Michael P. Friedlander
%   http://www.cs.ubc.ca/labs/scl/sparco
%   $Id$

% Check if A is square
if size(A,1) ~= size(A,2)
   error('Operator A must be square.');
end

% Set function handle
fun = @(x,mode) bicg_intrnl(A,x,mode);

if nargout == 0
   bicg(fun,b,varargin{:});
elseif nargout <= 5
   varargout = cell(1,nargout);
   [varargout{:}] = bicg(fun,b,varargin{:});
else
   error('Too many output arguments.');
end

% ======================================================================

function y = bicg_intrnl(A,x,mode)
if strcmp(mode,'notransp')
   y = A * x;
else
   y = A' * x;
end
