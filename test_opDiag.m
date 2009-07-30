function test_suite = test_opDiag
%test_opDiag  Unit tests for the diagonal operator
initTestSuite;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  
function test_opDiag_double
   
   r = randn(10,1);
   A = opDiag(r);
   assertEqual(diag(r),double(A))
   
end
