function varargout = lsqr(A,b,varargin)
%LSQR   LSQR Method.
%
%   See help of LSQR function provided by Matlab.

%   Copyright 2009, Ewout van den Berg and Michael P. Friedlander
%   http://www.cs.ubc.ca/labs/scl/sparco
%   $Id$


% Because of a bug in Matlab's LSQR code we need to set the maximum
% number of iterations manually
if isempty(varargin)
   varargin{1} = 1e-6; % Tolerance
end

if length(varargin) < 2
   varargin{2} = min([size(A,1),size(A,2),20]); % Maxit
end

% Set function handle
fun = @(x,mode) lsqr_intrnl(A,x,mode);

if nargout == 0
   lsqr(fun,b,varargin{:});
elseif nargout <= 6
   varargout = cell(1,nargout);
   [varargout{:}] = lsqr(fun,b,varargin{:});
else
   error('Too many output arguments.');
end

% ======================================================================

function y = lsqr_intrnl(A,x,mode)
if strcmp(mode,'notransp')
   y = A * x;
else
   y = A' * x;
end
