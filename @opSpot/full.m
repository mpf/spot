function x = full(A)
%FULL  Convert a Spot operator into a (dense) matrix.
%
%   X = full(A) converts the Spot operator A into a dense matrix X.
%
%   See also opSpot.double.

%   Copyright 2009, Ewout van den Berg and Michael P. Friedlander
%   See the file COPYING.txt for full copyright information.
%   Use the command 'spot.gpl' to locate this file.

%   http://www.cs.ubc.ca/labs/scl/spot

x = full(double(A));
