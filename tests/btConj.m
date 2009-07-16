function btConj(A)
%btConj(A) Unit test for conj
%this test assumes double is implemented correctly.

    a = double(conj(A));
    b = conj(double(A));
    assertEqual(a,b);

end