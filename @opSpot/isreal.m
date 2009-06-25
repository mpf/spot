function r = isreal(A)
%isreal True for real Spot operators.
%
%   isreal(A) returns 1 if the operator A does no have an imaginary part,
%   and 0 othersize.

%   Copyright 2009, Ewout van den Berg and Michael P. Friedlander
%   http://www.cs.ubc.ca/labs/scl/sparco
%   $Id: isreal.m 39 2009-06-12 20:59:05Z ewout78 $

r = ~A.cflag;
