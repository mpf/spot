function x = drandn(A)
%DRANDN  Normally distributed pseudorandom vector in the operator domain.
%
%   x = DRANDN(A) returns a pseudorandom vector in the domain of A.
%
%   See also opSpot.rrandn, randn.

%   Copyright 2009, Ewout van den Berg and Michael P. Friedlander
%   http://www.cs.ubc.ca/labs/scl/spot

n = size(A,2);

if isreal(A)
   x = randn(n,1);
else
   x = randn(n,1) + i*randn(n,1);
end
