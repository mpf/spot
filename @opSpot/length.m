function n = length(op)
%LENGTH  Maximum dimension of operator.
%
%   length(A) returns the maximum dimension of the operator A.

%   Copyright 2009, Ewout van den Berg and Michael P. Friedlander
%   See the file COPYING.txt for full copyright information.
%   Use the command 'spot.gpl' to locate this file.
   
%   http://www.cs.ubc.ca/labs/scl/spot

n = max(size(op));

