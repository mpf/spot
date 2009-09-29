function x = mrdivide(A,B)
%/  Slash or right matrix divide.
%
%   X = A/B is similar to Matlab's slash operator. If B is a Spot
%   operator and A is a matrix then X is computed as the transpose
%   of the solution to the least-squares problem
%
%   (*)  minimize  ||B'x - A'||_F;
%
%   when A is a vector, this is a standard least-squares problem.
%
%   If B is a scalar and A is a spot operator, then X = opFoG(1/B,A).
%
%   The least-squares problem (*) is solved using LSQR with default
%   parameters specified by spotparams.
%
%   See also mrdivide, opSpot.mldivide, opFoG, opInverse, spotparams.

%   Copyright 2009, Ewout van den Berg and Michael P. Friedlander
%   See the file COPYING.txt for full copyright information.
%   Use the command 'spot.gpl' to locate this file.
   
%   http://www.cs.ubc.ca/labs/scl/spot

if isscalar(A)
   x = (1/double(A)) * B;
else
   x = (B'\A')';   
end
