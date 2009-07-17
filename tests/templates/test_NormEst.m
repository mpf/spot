function test_NormEst(data)
%btNormEst(A, tol) Unit test for normest
%this test assumes double is implemented correctly.
A=data.operator;
%tol=data.relativeTol;
tol = 1e-5;

a = normest(A);
b = normest(double(A));
assertElementsAlmostEqual(a,b,'relative',tol);

end