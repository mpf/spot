function test_Conj(data)
%btConj(A) Unit test for conj
%this test assumes double is implemented correctly.
A=data.operator;
a = double(conj(A));
b = conj(double(A));
assertEqual(a,b);

end