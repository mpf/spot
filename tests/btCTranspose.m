function btCTranspose(A, tol)
%btCTranspose(A) Unit test for ctranspose
%this test assumes double is implemented correctly.

    a = double(ctranspose(A));
    b = ctranspose(double(A));
    assertElementsAlmostEqual(a,b, 'relative', tol);
    %assertEqual(a,b)
end