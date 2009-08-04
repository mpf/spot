function test_suite = test_diagonal
%test_diagonal  Unit tests for the diagonal operators
initTestSuite;
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function seed = setup
   seed = randn('state');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  
function test_diagonal_opSpot(seed)
   n = randi(100); k = randi(10);

   b = randn(n,k);
   d = randn(n,1);
   D = opDiag(d);
   
   assertEqual( diag(double(D)), d )
   assertEqual( diag(d)\b, D\b )
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  
function test_diagonal_diag(seed)
   n = randi(100);
   d = randn(n,1);
   assertEqual( double(diag(d)), double(opDiag(d)) ) 
end