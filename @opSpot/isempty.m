function result = isempty(A)
%isempty  True for empty operator.

%   Copyright 2009, Ewout van den Berg and Michael P. Friedlander
%   http://www.cs.ubc.ca/labs/scl/sparco
%   $Id: imag.m 7 2008-07-21 01:14:08Z ewout78 $

[m,n] = size(A);

if (m == 0) || (n == 0)
   result = true;
else
   result = false;
end

