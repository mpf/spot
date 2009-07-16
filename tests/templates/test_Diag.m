function test_Diag(data)
%btDiag(A) Unit test for diag
%this test assumes double is implemented correctly.
A=data.operator;

a = double(diag(A));
b = diag(double(A));
assertEqual(a,b);

end