function result = isscalar(A)
%isscalar  True if operator is a scalar.

%   Copyright 2009, Ewout van den Berg and Michael P. Friedlander
%   http://www.cs.ubc.ca/labs/scl/sparco
%   $Id$

[m,n] = size(A);
if (m == 1) && (n == 1)
   result = true;
else
   result = false;
end
