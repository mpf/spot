function y = plus(A,B)
%+   Sum of two operators.
%
%   See also opSum.

%   Copyright 2009, Ewout van den Berg and Michael P. Friedlander
%   See the file COPYING.txt for full copyright information.
%   Use the command 'spot.gpl' to locate this file.

%   http://www.cs.ubc.ca/labs/scl/spot

if nargin ~= 2
   error('Exactly two operators must be specified.')
end
y = opSum(A,B);
