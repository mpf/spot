function varargout = qmr(A,b,varargin)
%QMR   Quasi-Minimal Residual Method.
%
%   X = qmr(A,B) attempts to solve the square linear system A*X=B via
%   the QMR method.
%
%   This routine is simply a wrapper to Matlab's own QMR routine,
%   and the argument list variations described in Matlab's QMR
%   documentation are also allowed here.  The usage is identical to
%   Matlab's default version, except that the first argument must be a
%   Spot operator.

%   Copyright 2009, Ewout van den Berg and Michael P. Friedlander
%   See the file COPYING.txt for full copyright information.
%   Use the command 'spot.gpl' to locate this file.

%   http://www.cs.ubc.ca/labs/scl/spot

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
