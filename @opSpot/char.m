function str = char(A)
%char  Create a string representation of a Sparco operator.
%
%   char(A) converts the Spot operator into a string representation.

%   Copyright 2009, Ewout van den Berg and Michael P. Friedlander
%   http://www.cs.ubc.ca/labs/scl/sparco
%   $Id$

m     = A.size(1);
n     = A.size(2);
type  = A.type;
str   = sprintf('%s(%d,%d)',type,m,n);
