function test_suite = test_dottests
%test_dottests  Unit tests on operator-(sparse)matrix products.
% All linear operators should pass the "dottest".
initTestSuite;
end

function seed = setup
   rng('default');
   seed = [];
end

function test_dottests_elementary(seed)
   m = randi(100); n = randi(100);
   assertFalse(dottest(opEmpty(m,0)));      
   assertFalse(dottest(opEye(n)));          
   assertFalse(dottest(opOnes(m,n)));
   assertFalse(dottest(opZeros(m,n)));
end

function test_dottest_ensembles(seed) 
   m = randi(100); n = randi(100);
   assertFalse(dottest(opBernoulli(m,n)));  
   assertFalse(dottest(opBinary(m,n)));     
   assertFalse(dottest(opGaussian(m,n)));  
end

function test_dottest_fast(seed)
   m = randi(100); n = randi(100);
   assertFalse(dottest(opDCT(n)));          
   assertFalse(dottest(opDCT2(m,n)));       
   assertFalse(dottest(opDFT(n)));
   assertFalse(dottest(opDFT2(m,n)));
   assertFalse(dottest(opDirac(n)));
   assertFalse(dottest(opHaar(64)));
   %assertFalse(dottest(opHaar(64,5,1)));
   assertFalse(dottest(opHaar2(64,128)));
   assertFalse(dottest(opHadamard(256)));
   assertFalse(dottest(opHadamard(256,1)));
   assertFalse(dottest(opHeaviside(n)));
   assertFalse(dottest(opHeaviside(n,1)));
   
   %assertFalse(dottest(opSurfacelet([m,n],1)));assertEqual( A*xs, A*xf ));
  
   assertFalse(dottest(opToepGauss(m,n)));             
   assertFalse(dottest(opToepGauss(m,n,'circular')));  
   assertFalse(dottest(opToepGauss(m,n,'toeplitz',1)));
   assertFalse(dottest(opToepGauss(m,n,'circular',1)));
   
   assertFalse(dottest(opToepSign(m,n)));             
   assertFalse(dottest(opToepSign(m,n,'circular')));  
   assertFalse(dottest(opToepSign(m,n,'toeplitz',1)));
   assertFalse(dottest(opToepSign(m,n,'circular',1)));   
end

function test_dottest_matrix(seed)
   m = randi(100); n = randi(100);
   A = opMatrix(randn(m,n));
   B = opMatrix(randn(m,n));
   assertFalse(dottest(opBlockDiag(A,B)))
end

function test_dottest_extend(seed)
   p = randi(100); q = randi(100);
   % Check extensions greater than 2
   pext = p*(2+floor(rand));
   qext = q*(2+floor(rand));
   assertFalse(dottest(opExtend(p,q,pext,qext)))
   % Check extensions less than 1
   pext = p*floor(rand);
   qext = q*floor(rand);
   assertFalse(dottest(opExtend(p,q,pext,qext)))
end
