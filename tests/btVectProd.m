function btVectProd(A,tol)
%btLeftNRightProd(A,tol) Unit test for basic spot operators. 
%B=double(A)
%A*x is compared with B*x
%x'*A' is compared with x'*B'
%A*x is compared with (x'*A')'
%y*A*x is compared with y*B*x
%x'*A'*y' is compared with x'*B'*y'
%y*A*x is compared with x'*A'*y'


debug = false;
if nargin < 2
    tol = 1e-14;
end

B=double(A);
[m,n]=size(B);
x = randn(n,1);
y = randn(1,m);

if(debug)
    disp(abs(y*A*x - (x'*A'*y')'))
end
assertElementsAlmostEqual(A*x, (x'*A')', 'relative', tol)
assertElementsAlmostEqual(y*A*x,x'*A'*y', 'relative', tol);
assertElementsAlmostEqual(A*x, B*x, 'relative', tol)
assertElementsAlmostEqual(y*A*x, y*B*x, 'relative', tol);
assertElementsAlmostEqual(x'*A', x'*B', 'relative', tol)
assertElementsAlmostEqual(x'*A'*y', x'*B'*y', 'relative', tol);

x = i*x;
y = i*y;

if(debug)
    disp(abs(y*A*x - (x'*A'*y')'))
end
assertElementsAlmostEqual(A*x, (x'*A')', 'relative', tol)
assertElementsAlmostEqual(y*A*x,x'*A'*y', 'relative', tol);
assertElementsAlmostEqual(A*x, B*x, 'relative', tol)
assertElementsAlmostEqual(y*A*x, y*B*x, 'relative', tol);
assertElementsAlmostEqual(x'*A', x'*B', 'relative', tol)
assertElementsAlmostEqual(x'*A'*y', x'*B'*y', 'relative', tol);

x = randn(n,1)+x;
y = randn(1,m)+y;

if(debug)
    disp(abs(y*A*x - (x'*A'*y')'))
end
assertElementsAlmostEqual(A*x, (x'*A')', 'relative', tol)
%assertElementsAlmostEqual(y*A*x,x'*A'*y', 'relative', tol);
assertElementsAlmostEqual(A*x, B*x, 'relative', tol)
assertElementsAlmostEqual(y*A*x, y*B*x, 'relative', tol);
assertElementsAlmostEqual(x'*A', x'*B', 'relative', tol)
assertElementsAlmostEqual(x'*A'*y', x'*B'*y', 'relative', tol);

end
