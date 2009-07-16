function btDiag(A)
%btDiag(A) Unit test for diag
%this test assumes double is implemented correctly.

    a = double(diag(A));
    b = diag(double(A));
    assertEqual(a,b);

end