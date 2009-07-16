function test_Transpose(data)
%btTranspose(A, tol) Unit test for transpose
%this test assumes double is implemented correctly.
A=data.operator;
tol=data.relativeTol;

a = double(transpose(A));
b = transpose(double(A));
assertElementsAlmostEqual(a,b,'relative', tol);

end