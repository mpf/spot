function test_suite = test_opSparseBinary
%testGaussian  Unit tests for the sparse binary operator.
initTestSuite;
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function seed = setup
   seed = rng('default');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  
function test_opSparseBinary_against_randn(seed)
   m = randi(100); n = randi(100);

   rng(seed);  A1 = opSparseBinary(m,n,m  );
   rng(seed);  A2 = opSparseBinary(m,n,m+1);

   x = randn(n,2);
   assertEqual(  A1*x , A2*x  );
end
