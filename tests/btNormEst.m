function btNormEst(A, tol)
%btNormEst(A, tol) Unit test for normest
%this test assumes double is implemented correctly.

a = normest(A);
b = normest(double(A));
assertElementsAlmostEqual(a,b,'relative',tol);

end