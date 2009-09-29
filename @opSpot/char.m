function str = char(A)
%CHAR  Create a string representation of a Spot operator.
%
%   char(A) converts the Spot operator into a string representation.

%   Copyright 2009, Ewout van den Berg and Michael P. Friedlander
%   See the file COPYING.txt for full copyright information.
%   Use the command 'spot.gpl' to locate this file.

%   http://www.cs.ubc.ca/labs/scl/spot

m     = A.size(1);
n     = A.size(2);
type  = A.type;
str   = sprintf('%s(%d,%d)',type,m,n);
