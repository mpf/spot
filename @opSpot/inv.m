function y = inv(A)

%   Copyright 2009, Ewout van den Berg and Michael P. Friedlander
%   http://www.cs.ubc.ca/labs/scl/spot

if size(A,1) ~= size(A,2)
   error('Operator must be square.');
else
   y = opInverse(A);
end
