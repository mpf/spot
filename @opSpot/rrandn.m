function x = rrandn(A)
%RRANDN  Normally distributed pseudorandom vector in the operator range.
%
%   rrandn(A) returns a pseudorandom vector in the range of A.
%
%   See also opSpot.drandn, randn.

%   Copyright 2009, Ewout van den Berg and Michael P. Friedlander
%   See the file COPYING.txt for full copyright information.
%   Use the command 'spot.gpl' to locate this file.

%   http://www.cs.ubc.ca/labs/scl/spot

m = A.m;

if isreal(A)
   x = randn(m,1);
else
   x = randn(m,1) + 1i*randn(m,1);
end
