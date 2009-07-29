function test_suite = test_solves
%test_solves  Unit tests for opInverse and friends.
initTestSuite;
end

function test_solves_opInverse

   n = 21; A = gallery('moler',n);  b = A*ones(n,1);
   tol = 1e-9;  maxit = 15;  M = diag([10:-1:1 1 1:10]);
   Aop = opMatrix(A);
   
   x1 = opInverse(Aop)*b;   
   [x2,ff2,rr2,it2,rv2] = pcg(Aop,b,tol,maxit,M);
   
   assertElementsAlmostEqual(x1,x2)
   
end

function y = afun_diff(x,n,mode)
   if mode == 2      % y = A'*x
      y = 4 * x;
      y(1:n-1) = y(1:n-1) - 2 * x(2:n);
      y(2:n) = y(2:n) - x(1:n-1);
   else
      y = 4 * x;
      y(2:n) = y(2:n) - 2 * x(1:n-1);
      y(1:n-1) = y(1:n-1) - x(2:n);
   end
end

function y = afun_diff2(x,n)
   y = 4 * x;
   y(2:n) = y(2:n) - 2 * x(1:n-1);
   y(1:n-1) = y(1:n-1) - 2 * x(2:n);
end

function y = afun_wilk(x,n)
   y = [0; x(1:n-1)] + [((n-1)/2:-1:0)'; (1:(n-1)/2)'].*x+[x(2:n); 0];
end

function y = mfun_wilk(r,n)
   y = r ./ [((n-1)/2:-1:1)'; 1; (1:(n-1)/2)'];
end