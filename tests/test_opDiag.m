function test_suite = test_opDiag
%test_opDiag  Unit tests for the opDiag operator
initTestSuite;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function seed = setup
   seed = rng('default');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  
function test_opDiag_diag(seed)
   n = randi(100);

   d = randn(n,1) + 1i*randn(n,1);
   D = opDiag(d);
   
   assertEqual( diag(double(D)), d )
   assertEqual( diag(D), d )

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  
function test_opDiag_class(seed)
   n = randi(100);
   d = randn(n,1);
   assertEqual( double(diag(d)), double(opDiag(d)) ) 
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  
function test_opDiag_mulitply(seed)
   n = randi(100); k = randi(10);
   d = randn(n,1) + 1i*randn(n,1);
   b = randn(n,k) + 1i*randn(n,k);
   D = opDiag(d);
   assertEqual( D*b, bsxfun(@times,d,b) )
   assertEqual( D'*b, bsxfun(@times,conj(d),b) )
   assertEqual( D.'*b, bsxfun(@times,d,b) ) 
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  
function test_opDiag_divide(seed)
   n = randi(100); k = randi(10);
   d = randn(n,1) + 1i*randn(n,1);
   b = randn(n,k) + 1i*randn(n,k);
   D = opDiag(d);
   assertEqual( D\b, bsxfun(@ldivide,d,b) )
   assertEqual( D'\b, bsxfun(@ldivide,conj(d),b) )
   assertEqual( D.'\b, bsxfun(@ldivide,d,b) ) 
end
