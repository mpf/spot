function d = diag(A)

%   Copyright 2009, Ewout van den Berg and Michael P. Friedlander
%   http://www.cs.ubc.ca/labs/scl/sparco
%   $Id: double.m 13 2009-06-28 02:56:46Z mpf $

[m,n] = size(A);
k = min(m,n);

d = zeros(k,1);
for i=1:k
   v = zeros(n,1); v(i) = 1;
   w = A*v;
   d(i) = w(i);
end
