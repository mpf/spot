 function test_suite = test_sum
 %test_sum Unit tests for sum
 initTestSuite;
 end
 
 function test_sum_explicit
         
     Aex = rand(100);
     Aop = opMatrix(Aex);
     
     colSum_ex = sum(Aex,1);
     colSum_op = sum(Aop,1);
     assertElementsAlmostEqual(colSum_ex,colSum_op);
     
     rowSum_ex = sum(Aex,1);
     rowSum_op = sum(Aop,1);
     assertElementsAlmostEqual(rowSum_ex,rowSum_op);
     
end