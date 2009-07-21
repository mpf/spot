function test_VectProd(data)
%btLeftNRightProd(A,tol) Unit test for basic spot operators. 
%B=double(A)
%A*x is compared with B*x
%x'*A' is compared with x'*B'
%A*x is compared with (x'*A')'
%y*A*x is compared with y*B*x
%x'*A'*y' is compared with x'*B'*y'
%y*A*x is compared with x'*A'*y'
A=data.operator;
tol=data.relativeTol;

debug = false;
B=double(A);
[m,n]=size(B);

% testing with purely real vectors
x = randn(n,1);
y = randn(1,m);

if(debug)
    disp(['y*A*x: ', num2str(y*A*x)]);
    disp(['(x''*A''*y'')'': )', num2str((x'*A'*y')')]);
    disp(['y*B*x: ', num2str(y*B*x)]);
    disp(['(x''*B''*y'')'': )', num2str((x'*B'*y')')]);
end
assertVectorsAlmostEqual(A*x, (x'*A')', 'relative', tol)
assertVectorsAlmostEqual(y*A*x,x'*A'*y', 'relative', tol);
assertVectorsAlmostEqual(A*x, B*x, 'relative', tol);
assertVectorsAlmostEqual(y*A*x, y*B*x, 'relative', tol);
assertVectorsAlmostEqual(x'*A', x'*B', 'relative', tol);
assertVectorsAlmostEqual(x'*A'*y', x'*B'*y', 'relative', tol);

% testing with purely imaginary vectors
x = i*x;
y = i*y;

if(debug)
    disp(['y*A*x: ', num2str(y*A*x)]);
    disp(['(x''*A''*y'')'': )', num2str((x'*A'*y')')]);
    disp(['y*B*x: ', num2str(y*B*x)]);
    disp(['(x''*B''*y'')'': )', num2str((x'*B'*y')')]);
end
assertVectorsAlmostEqual(A*x, (x'*A')', 'relative', tol)
assertVectorsAlmostEqual(y*A*x,x'*A'*y', 'relative', tol);
assertVectorsAlmostEqual(A*x, B*x, 'relative', tol);
assertVectorsAlmostEqual(y*A*x, y*B*x, 'relative', tol);
assertVectorsAlmostEqual(x'*A', x'*B', 'relative', tol);
assertVectorsAlmostEqual(x'*A'*y', x'*B'*y', 'relative', tol);

% testing with the entire complex domain
x = randn(n,1)+x;
y = randn(1,m)+y;

if(debug)
    disp(['y*A*x: ', num2str(y*A*x)]);
    disp(['(x''*A''*y'')'': )', num2str((x'*A'*y')')]);
    disp(['y*B*x: ', num2str(y*B*x)]);
    disp(['(x''*B''*y'')'': )', num2str((x'*B'*y')')]);
end
assertVectorsAlmostEqual(A*x, (x'*A')', 'relative', tol)
assertVectorsAlmostEqual(y*A*x,x'*A'*y', 'relative', tol);
assertVectorsAlmostEqual(A*x, B*x, 'relative', tol);
assertVectorsAlmostEqual(y*A*x, y*B*x, 'relative', tol);
assertVectorsAlmostEqual(x'*A', x'*B', 'relative', tol);
assertVectorsAlmostEqual(x'*A'*y', x'*B'*y', 'relative', tol);

end

%endoftemplate