function test_IsReal(data)
%btIsReal(A) Unit test for isreal
%this test assumes double is implemented correctly.
A=data.operator;

    a = isreal(A);
    b = isreal(double(A));
    assertEqual(a,b);

end