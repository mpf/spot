function test_Char(data)

A = data.operator;
opType = data.operatorType;

[m,n]=size(A);
assertEqual(char(A),[opType,'(',num2str(m),',',num2str(n),')']);

end