function test_suite = test_iterative
%test_iterative  Unit tests for iterative methods
initTestSuite;
end

function test_iterative_bicg

   n  = 100; on = ones(n,1); A = spdiags([-2*on 4*on -on],-1:1,n,n);
   b  = sum(A,2); tol = 1e-8; maxit = 15;
   M1 = spdiags([on/(-2) on],-1:0,n,n);
   M2 = spdiags([4*on -on],0:1,n,n);
   [x1,FLAG,RELRES,ITER] = bicg(A,b,tol,maxit,M1,M2);
   
   Aop = opFunction(n,n,@(x,mode)afun_bicg(x,n,mode));
   [x2,FLAG,RELRES,ITER] = bicg(Aop,b,tol,maxit,M1,M2);
   
   assertElementsAlmostEqual(x1,x2)
   
end

function test_iterative_bicgstab

   n = 21; A = gallery('wilk',n);  b = sum(A,2);
   tol = 1e-12;  maxit = 15; M = diag([10:-1:1 1 1:10]);
   [x1,flag,relres,iter] = bicgstab(A,b,tol,maxit,M);
   
   Aop = opFunction(n,n,@(x,mode)afun_bicgstab(x,n));
   [x2,FLAG,RELRES,ITER] = bicgstab(Aop,b,tol,maxit,@(x)mfun_bicgstab(x,n));
   
   assertElementsAlmostEqual(x1,x2)
   
end

function y = afun_bicg(x,n,mode)
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

function y = afun_bicgstab(x,n)
   y = [0; x(1:n-1)] + [((n-1)/2:-1:0)'; (1:(n-1)/2)'].*x+[x(2:n); 0];
end

function y = mfun_bicgstab(r,n)
   y = r ./ [((n-1)/2:-1:1)'; 1; (1:(n-1)/2)'];
end