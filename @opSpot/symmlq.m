function varargout = symmlq(A,b,varargin)
%SYMMLQ   Symetric LQ Method.
%
%   See help of SYMMLQ function provided by Matlab.

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
   symmlq(fun,b,varargin{:});
elseif nargout <= 6
   varargout = cell(1,nargout);
   [varargout{:}] = symmlq(fun,b,varargin{:});
else
   error('Too many output arguments.');
end
