function M = double(A)
%double  Converts a Spot operator to matrix.
%
%   M = double(A) converts a Spot operator to an explicit
%   matrix.

%   Copyright 2009, Ewout van den Berg and Michael P. Friedlander
%   http://www.cs.ubc.ca/labs/scl/sparco
%   $Id$

M = A*speye(size(A,2));
