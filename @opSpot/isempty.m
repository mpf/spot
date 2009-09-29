function result = isempty(A)
%ISEMPTY  True for empty operator.
%
%   isempty(A) returns true if A is an empty operator.
%
%   See also opEmpty.

%   Copyright 2009, Ewout van den Berg and Michael P. Friedlander
%   See the file COPYING.txt for full copyright information.
%   Use the command 'spot.gpl' to locate this file.

%   http://www.cs.ubc.ca/labs/scl/spot

if (A.m == 0) || (A.n == 0)
   result = true;
else
   result = false;
end

