function test_CTranspose(data)
%btCTranspose(A) Unit test for ctranspose
%this test assumes double is implemented correctly.
A=data.operator;
tol=data.relativeTol;
    a = double(ctranspose(A));
    b = ctranspose(double(A));
    assertElementsAlmostEqual(a,b, 'relative', tol);
    %assertEqual(a,b)
end