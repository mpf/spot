function test_suite = test_mvsolves
%test_solves  Unit tests for opInverse and friends.
initTestSuite;
end

function test_mvsolves_mrdivide

n = 3; A = magic(n); b = [(1:n)' (1:n)'];
x1 = b'/A;

spotparams('cgtol',1e-8,'cgitsfact',3,'cgshow',0);
Aop = opMatrix(A);
x2 = b'/Aop;

assertElementsAlmostEqual(x1,x2)

end

function test_mvsolves_mldivide

n  = 100; on = ones(n,1); A = spdiags([-2*on 4*on -on],-1:1,n,n);
b  = [sum(A,2) sum(A,2)]; tol = 1e-8; maxit = 60;
for i = 1:2
    [x1(:,i),flag1] = lsqr(A,b(:,i),tol,maxit);
end

spotparams('cgtol',1e-8,'cgitsfact',3,'cgshow',0);
Aop = opFunction(n,n,@(x,mode)afun_diff(x,n,mode));
x2 = Aop\b;

assertElementsAlmostEqual(x1,x2,'relative',1e-6)

end

function test_mvsolves_opInverse

n = 21; A = gallery('moler',n);  b = A*ones(n,1);
Aop = opMatrix(A);
x = opInverse(Aop)*b;
r = b - Aop*x;
assertTrue(norm(r)/norm(b)<1e-6)

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