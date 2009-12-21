function y = kron(varargin)
%KRON   Kronecker tensor product of operators.
%
%   kron(A,B) is the Kroneker tensor product of A and B.
%
%   kron(A,B,C,...) is the Kroneker product of A,B,C,...
%
%   See also opKron.

%   Copyright 2009, Ewout van den Berg and Michael P. Friedlander
%   See the file COPYING.txt for full copyright information.
%   Use the command 'spot.gpl' to locate this file.

%   http://www.cs.ubc.ca/labs/scl/spot

if nargin < 2
    error('At least two operators must be specified.')
end
y = opKron(varargin{:});

end % function kron
