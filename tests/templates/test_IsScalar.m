function test_IsScalar(data)
%btIsScalar(A) Unit test for isempty
%this test assumes double is implemented correctly.
A=data.operator;

    a = isscalar(A);
    b = isscalar(double(A));
    assertEqual(a,b);

end