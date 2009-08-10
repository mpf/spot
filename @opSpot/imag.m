function A = imag(A)
%IMAG  Complex imaginary part.

%   Copyright 2009, Ewout van den Berg and Michael P. Friedlander
%   http://www.cs.ubc.ca/labs/scl/spot

   if isreal(A)
      [m,n] = size(A);
      A = opZeros(m,n);
   else
      A =  opImag(A);
   end
end % function imag
