function A = real(A)
%REAL  Complex real part.

%   Copyright 2009, Ewout van den Berg and Michael P. Friedlander
%   http://www.cs.ubc.ca/labs/scl/spot

   if isreal(A)
      % relax
   else
      A = opReal(A);
   end
   
end % function real
