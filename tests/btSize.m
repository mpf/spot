function btSize(A)
%btSize(A) Unit test for size
%this test assumes double is implemented correctly.

a = size(A);
b = size(double(A));
assertEqual(a,b);


end