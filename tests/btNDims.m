function btNDims(A)
%btNDims(A) Unit test for ndims
%this test assumes double is implemented correctly.

a = ndims(A);
b = ndims(double(A));
assertEqual(a,b);

end