function y = mldivide(A,B)

%   Copyright 2009, Ewout van den Berg and Michael P. Friedlander
%   http://www.cs.ubc.ca/labs/scl/sparco
%   $Id$

if isscalar(A)
   y = (1/A) * B;
else
   y = opInverse(A) * B;
end

