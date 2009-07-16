function test_NDims(data)
%btNDims(A) Unit test for ndims
%this test assumes double is implemented correctly.
A=data.operator;

a = ndims(A);
b = ndims(double(A));
assertEqual(a,b);

end