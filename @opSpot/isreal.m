function result = isreal(A)
%isreal  True for real operator.

%   Copyright 2009, Ewout van den Berg and Michael P. Friedlander
%   http://www.cs.ubc.ca/labs/scl/sparco
%   $Id$

% Get size information
result = ~A.cflag;