function btIsScalar(A)
%btIsScalar(A) Unit test for isempty
%this test assumes double is implemented correctly.

    a = isscalar(A);
    b = isscalar(double(A));
    assertEqual(a,b);

end