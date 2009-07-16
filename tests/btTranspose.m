function btTranspose(A, tol)
%btTranspose(A, tol) Unit test for transpose
%this test assumes double is implemented correctly.

a = double(transpose(A));
b = transpose(double(A));
assertElementsAlmostEqual(a,b);

end