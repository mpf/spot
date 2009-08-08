function result = transpose(A)
%.'   Operator tranpose.
%   A.' is the (non-conjugate) transpose of A.
%
%   TRANSPOSE(A) is called for the syntax A.' when A is an operator.
%
%   See also opTranspose, opCTranspose, ctranspose.
   
%   Copyright 2009, Ewout van den Berg and Michael P. Friedlander
%   http://www.cs.ubc.ca/labs/scl/spot

result = opTranspose(A);
