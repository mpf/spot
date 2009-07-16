function btIsReal(A)
%btIsReal(A) Unit test for isreal
%this test assumes double is implemented correctly.

    a = isreal(A);
    b = isreal(double(A));
    assertEqual(a,b);

end