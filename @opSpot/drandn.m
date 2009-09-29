function x = drandn(A)
%DRANDN  Normally distributed pseudorandom vector in the operator domain.
%
%   drandn(A) returns a pseudorandom vector in the domain of A.
%
%   See also opSpot.rrandn, randn.

%   Copyright 2009, Ewout van den Berg and Michael P. Friedlander
%   See the file COPYING.txt for full copyright information.
%   Use the command 'spot.gpl' to locate this file.

%   http://www.cs.ubc.ca/labs/scl/spot

n = A.n;

if isreal(A)
   x = randn(n,1);
else
   x = randn(n,1) + 1i*randn(n,1);
end
