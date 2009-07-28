function test_suite = test_iterative
%test_iterative  Unit tests for iterative methods
initTestSuite;
end

function test_iterative_pcg

   n = 21; A = gallery('moler',n);  b1 = A*ones(n,1);
   tol = 1e-6;  maxit = 15;  M = diag([10:-1:1 1 1:10]);
   [x1,flag1,relres1,iter1,resvec1] = pcg(A,b1,tol,maxit,M);
   
   Aop = opFunction(n,n,@(x,mode)gallery('moler',n)*x);
   b2 = Aop*ones(n,1);
   [x2,flag2,relres2,iter2,resvec2] = pcg(Aop,b2,tol,maxit,M);
   
   assertElementsAlmostEqual(x1,x2)
   assertElementsAlmostEqual(flag1,flag2)
   assertElementsAlmostEqual(relres1,relres2)
   assertElementsAlmostEqual(iter1,iter2)
   assertElementsAlmostEqual(resvec1,resvec2)
   
end

function test_iterative_bicg

   n  = 100; on = ones(n,1); A = spdiags([-2*on 4*on -on],-1:1,n,n);
   b  = sum(A,2); tol = 1e-8; maxit = 15;
   M1 = spdiags([on/(-2) on],-1:0,n,n);
   M2 = spdiags([4*on -on],0:1,n,n);
   [x1,flag1,relres1,iter1] = bicg(A,b,tol,maxit,M1,M2);
   
   Aop = opFunction(n,n,@(x,mode)afun_diff(x,n,mode));
   [x2,flag2,relres2,iter2] = bicg(Aop,b,tol,maxit,M1,M2);
   
   assertElementsAlmostEqual(x1,x2)
   assertElementsAlmostEqual(flag1,flag2)
   assertElementsAlmostEqual(relres1,relres2)
   assertElementsAlmostEqual(iter1,iter2)
   
end

function test_iterative_lsqr

   n  = 100; on = ones(n,1); A = spdiags([-2*on 4*on -on],-1:1,n,n);
   b  = sum(A,2); tol = 1e-8; maxit = 15;
   M1 = spdiags([on/(-2) on],-1:0,n,n);
   M2 = spdiags([4*on -on],0:1,n,n);
   [x1,flag1,relres1,iter1] = lsqr(A,b,tol,maxit,M1,M2);
   
   Aop = opFunction(n,n,@(x,mode)afun_diff(x,n,mode));
   [x2,flag2,relres2,iter2] = lsqr(Aop,b,tol,maxit,M1,M2);
   
   assertElementsAlmostEqual(x1,x2)
   assertElementsAlmostEqual(flag1,flag2)
   assertElementsAlmostEqual(relres1,relres2)
   assertElementsAlmostEqual(iter1,iter2)
   
end

function test_iterative_qmr

   n  = 100; on = ones(n,1); A = spdiags([-2*on 4*on -on],-1:1,n,n);
   b  = sum(A,2); tol = 1e-8; maxit = 15;
   M1 = spdiags([on/(-2) on],-1:0,n,n);
   M2 = spdiags([4*on -on],0:1,n,n);
   [x1,flag1,relres1,iter1] = qmr(A,b,tol,maxit,M1,M2);
   
   Aop = opFunction(n,n,@(x,mode)afun_diff(x,n,mode));
   [x2,flag2,relres2,iter2] = qmr(Aop,b,tol,maxit,M1,M2);
   
   assertElementsAlmostEqual(x1,x2)
   assertElementsAlmostEqual(flag1,flag2)
   assertElementsAlmostEqual(relres1,relres2)
   assertElementsAlmostEqual(iter1,iter2)
   
end

function test_iterative_minres

   n = 100; on = ones(n,1); A = spdiags([-2*on 4*on -2*on],-1:1,n,n);
   b = sum(A,2); tol = 1e-10; maxit = 50; M = spdiags(4*on,0,n,n);
   [x1,flag1,relres1,iter1,resvec1] = minres(A,b,tol,maxit,M);
   
   Aop = opFunction(n,n,@(x,mode)afun_diff2(x,n));
   [x2,flag2,relres2,iter2,resvec2] = minres(Aop,b,tol,maxit,M);
   
   assertElementsAlmostEqual(x1,x2)
   assertElementsAlmostEqual(flag1,flag2)
   assertElementsAlmostEqual(relres1,relres2)
   assertElementsAlmostEqual(iter1,iter2)
   assertElementsAlmostEqual(resvec1,resvec2)
   
end

function test_iterative_bicgstab

   n = 21; A = gallery('wilk',n);  b = sum(A,2);
   tol = 1e-12;  maxit = 15; M = diag([10:-1:1 1 1:10]);
   [x1,flag1,relres1,iter1] = bicgstab(A,b,tol,maxit,M);
   
   Aop = opFunction(n,n,@(x,mode)afun_wilk(x,n));
   [x2,flag2,relres2,iter2] = bicgstab(Aop,b,tol,maxit,@(x)mfun_wilk(x,n));
   
   assertElementsAlmostEqual(x1,x2)
   assertElementsAlmostEqual(flag1,flag2)
   assertElementsAlmostEqual(relres1,relres2)
   assertElementsAlmostEqual(iter1,iter2)
   
end

function test_iterative_cgs
   
   n = 21; A = gallery('wilk',n);  b = sum(A,2);
   tol = 1e-12;  maxit = 15; M = diag([10:-1:1 1 1:10]);
   [x1,flag1,relres1,iter1] = cgs(A,b,tol,maxit,M);

   Aop = opFunction(n,n,@(x,mode)afun_wilk(x,n));
   [x2,flag2,relres2,iter2] = cgs(Aop,b,tol,maxit,@(x)mfun_wilk(x,n));
   
   assertElementsAlmostEqual(x1,x2)
   assertElementsAlmostEqual(flag1,flag2)
   assertElementsAlmostEqual(relres1,relres2)
   assertElementsAlmostEqual(iter1,iter2)   
   
end

function test_iterative_gmres
   
   n = 21; A = gallery('wilk',n);  b = sum(A,2);
   tol = 1e-12;  maxit = 15; M = diag([10:-1:1 1 1:10]);
   [x1,flag1,relres1,iter1] = gmres(A,b,10,tol,maxit,M);

   Aop = opFunction(n,n,@(x,mode)afun_wilk(x,n));
   [x2,flag2,relres2,iter2] = gmres(Aop,b,10,tol,maxit,@(x)mfun_wilk(x,n));
   
   assertElementsAlmostEqual(x1,x2)
   assertElementsAlmostEqual(flag1,flag2)
   assertElementsAlmostEqual(relres1,relres2)
   assertElementsAlmostEqual(iter1,iter2)   
   
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