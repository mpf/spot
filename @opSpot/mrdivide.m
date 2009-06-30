function y = mrdivide(A,B)

% Use lsqr to solve series of equations, one for each col of B.

%   Copyright 2009, Ewout van den Berg and Michael P. Friedlander
%   http://www.cs.ubc.ca/labs/scl/sparco
%   $Id$

if isscalar(B)
   y = (1/double(B)) * A;
else
   % Check sizes A and B
   if size(A,2) ~= size(B,1)
      error('Operator dimensions must agree.');
   end

   y = A * inv(B);
end
