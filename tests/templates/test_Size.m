function test_Size(data)
%btSize(A) Unit test for size
%this test assumes double is implemented correctly.
A=data.operator;

a = size(A);
b = size(double(A));
assertEqual(a,b);


end