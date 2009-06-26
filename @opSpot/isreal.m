function result = isreal(A)
%isreal  True for real operator.

%   Copyright 2009, Ewout van den Berg and Michael P. Friedlander
%   http://www.cs.ubc.ca/labs/scl/sparco
%   $Id: isreal.m 39 2009-06-12 20:59:05Z ewout78 $

% Get size information
result = ~A.cflag;