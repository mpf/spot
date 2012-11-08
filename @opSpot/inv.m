function y = inv(A)
%INV   Inverse of a linear operator.
%
%   inv(A) returns the operator inverse of A. This routine is
%   a simple front-end to opInverse.
%
%   See also opInverse, opSpot.pinv, opPInverse.

%   Copyright 2009, Ewout van den Berg and Michael P. Friedlander
%   See the file COPYING.txt for full copyright information.
%   Use the command 'spot.gpl' to locate this file.

%   http://www.cs.ubc.ca/labs/scl/spot

y = opInverse(A);
