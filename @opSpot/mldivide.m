function y = mldivide(A,B)

%   Copyright 2009, Ewout van den Berg and Michael P. Friedlander
%   http://www.cs.ubc.ca/labs/scl/sparco
%   $Id$

if isscalar(A)
   y = (1/double(A)) * B;
else
   % Check sizes A and B
   if size(A,2) ~= size(B,1)
      error('Operator dimensions must agree.');
   end
    
   y = inv(A) * B;
end

