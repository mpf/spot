function test_Char(data)
%test_Char(A) Unit test for char
%this test assumes double is implemented correctly.

A = data.operator;
opType = data.operatorType;

[m,n]=size(double(A));
assertEqual(char(A),[opType,'(',num2str(m),',',num2str(n),')']);

end