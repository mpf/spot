function [e,cnt] = normest(S,tol)
%NORMEST Estimate the matrix 2-norm.
%   NORMEST(S) is an estimate of the 2-norm of the matrix S.
%   NORMEST(S,tol) uses relative error tol instead of 1e-6.
%   [nrm,cnt] = NORMEST(..) also gives the number of iterations used.
%
%   This function is a minor adaptation of Matlab's built-in NORMEST.
%
%   See also NORM, COND, RCOND, CONDEST.

if nargin < 2, tol = 1.e-6; end
maxiter = 100; % should never take this many iterations. 
n = size(S,2);
x = rand(n,1);
cnt = 0;
e = norm(x);
if e == 0, return, end
x = x/e;
e0 = 0;
while abs(e-e0) > tol*e
   e0 = e;
   Sx = S*x;
   if nnz(Sx) == 0
      Sx = rand(size(Sx));
   end
   x = S'*Sx;
   normx = norm(x);
   e = normx/norm(Sx);
   x = x/normx;
   cnt = cnt+1;
   if cnt > maxiter
      warning('MATLAB:normest:notconverge', '%s%d%s%g', ...
              'NORMEST did not converge for ', maxiter, ' iterations with tolerance ', tol);
      break;
   end
end
