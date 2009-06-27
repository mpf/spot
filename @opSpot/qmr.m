function varargout = qmr(A,b,varargin)
%QMR   Quasi-Minimal Residual Method.
%
%   See help of QMR function provided by Matlab.

%   Copyright 2009, Ewout van den Berg and Michael P. Friedlander
%   http://www.cs.ubc.ca/labs/scl/sparco
%   $Id$

% Set up multiplication function
fun = @(x,mode) qmr_intrnl(A,x,mode);

if nargout == 0
   qmr(fun,b,varargin{:});
elseif nargout <= 5
   varargout = cell(1,nargout);
   [varargout{:}] = qmr(fun,b,varargin{:});
else
   error('Too many output arguments.');
end

% ======================================================================

function y = qmr_intrnl(A,x,mode)
if strcmp(mode,'notransp')
   y = A * x;
else
   y = A' * x;
end
