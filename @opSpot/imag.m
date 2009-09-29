function A = imag(A)
%IMAG  Complex imaginary part.
%
%   imag(A) returns a new operator comprised of imaginary part of A.
%
%   See also opSpot.real, opImag.

%   Copyright 2009, Ewout van den Berg and Michael P. Friedlander
%   See the file COPYING.txt for full copyright information.
%   Use the command 'spot.gpl' to locate this file.

%   http://www.cs.ubc.ca/labs/scl/spot

   if isreal(A)
      [m,n] = size(A);
      A = opZeros(m,n);
   else
      A =  opImag(A);
   end
end % function imag
