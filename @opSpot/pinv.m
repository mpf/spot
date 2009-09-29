function y = pinv(A)
%PINV   Pseudo-inverse of an operator
%
%   pinv(A) returns the operator pseudo-inverse of A.
%
%   See also opSpot.inv, opPInverse, opInverse.

%   Copyright 2009, Ewout van den Berg and Michael P. Friedlander
%   See the file COPYING.txt for full copyright information.
%   Use the command 'spot.gpl' to locate this file.

%   http://www.cs.ubc.ca/labs/scl/spot

y = opPInverse(A);
