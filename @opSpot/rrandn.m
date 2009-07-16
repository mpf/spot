function x = rrandn(A)
%rrandn  Normally distributed pseudorandom vector in the operator range.
%
%   x = rrandn(A) returns a pseudorandom vector in the range of A.
%
%   See also opSpot.drandn, randn.

%   Copyright 2009, Ewout van den Berg and Michael P. Friedlander
%   http://www.cs.ubc.ca/labs/scl/sparco
%   $Id: uminus.m 13 2009-06-28 02:56:46Z mpf $

m = size(A,1);

if isreal(A)
   x = randn(m,1);
else
   x = randn(m,1) + i*randn(m,1);
end
