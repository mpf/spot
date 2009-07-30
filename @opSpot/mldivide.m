function x = mldivide(A,B)
%\  Backslash or left matrix divide.
%   X = A\B is similar to Matlab's backslash operator. If A is a Spot
%   operator and B is a vector, then X is computed as the solution to the
%   least-squares problem
%
%   (*)  minimize  ||Ax - b||_2.
%
%   If A is a scalar and B is a spot operator, then X = opFoG(1/A,B).
%
%   The least-squares problem (*) is solved using LSQR with default
%   parameters specified by spotparams.
%
%   See also mldivide, @opSpot/mrdivide, opFoG, opInverse, spotparams.

%   Copyright 2009, Ewout van den Berg and Michael P. Friedlander
%   http://www.cs.ubc.ca/labs/scl/spot

if isscalar(A)
   x = (1/double(A)) * B;

else
   
   [m,n] = size(A);
   [p,q] = size(B);
   
   if n ~= p
      error('Operator and RHS dimensions must agree.')
   end

   opts = spotparams;     % Grab default options
   x = zeros(m,q);        % Preallocate solution

   maxits = opts.cgitsfact * min(m,min(n,20));
   for i=1:q
      x(:,i) = spot.solvers.lsqr(m,n,A,B(:,i), ...
         opts.cgdamp,opts.cgtol,opts.cgtol,opts.conlim,maxits,opts.cgshow);
   end
end
