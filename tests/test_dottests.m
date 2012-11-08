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
   assertFalse(spot.utils.dottest(opEmpty(m,0)));      
   assertFalse(spot.utils.dottest(opEye(n)));          
   assertFalse(spot.utils.dottest(opOnes(m,n)));
   assertFalse(spot.utils.dottest(opZeros(m,n)));
end

function test_dottest_ensembles(seed) 
   m = randi(100); n = randi(100);
   assertFalse(spot.utils.dottest(opBernoulli(m,n)));  
   assertFalse(spot.utils.dottest(opBinary(m,n)));     
   assertFalse(spot.utils.dottest(opGaussian(m,n)));  
end

function test_dottest_fast(seed)
   m = randi(100); n = randi(100);
   assertFalse(spot.utils.dottest(opDCT(n)));          
   assertFalse(spot.utils.dottest(opDCT2(m,n)));       
   assertFalse(spot.utils.dottest(opDFT(n)));
   assertFalse(spot.utils.dottest(opDFT2(m,n)));
   assertFalse(spot.utils.dottest(opDirac(n)));
   assertFalse(spot.utils.dottest(opHaar(64)));
   %assertFalse(spot.utils.dottest(opHaar(64,5,1)));
   assertFalse(spot.utils.dottest(opHaar2(64,128)));
   assertFalse(spot.utils.dottest(opHadamard(256)));
   assertFalse(spot.utils.dottest(opHadamard(256,1)));
   assertFalse(spot.utils.dottest(opHeaviside(n)));
   assertFalse(spot.utils.dottest(opHeaviside(n,1)));
   
   %assertFalse(spot.utils.dottest(opSurfacelet([m,n],1)));assertEqual( A*xs, A*xf ));
  
   assertFalse(spot.utils.dottest(opToepGauss(m,n)));             
   assertFalse(spot.utils.dottest(opToepGauss(m,n,'circular')));  
   assertFalse(spot.utils.dottest(opToepGauss(m,n,'toeplitz',1)));
   assertFalse(spot.utils.dottest(opToepGauss(m,n,'circular',1)));
   
   assertFalse(spot.utils.dottest(opToepSign(m,n)));             
   assertFalse(spot.utils.dottest(opToepSign(m,n,'circular')));  
   assertFalse(spot.utils.dottest(opToepSign(m,n,'toeplitz',1)));
   assertFalse(spot.utils.dottest(opToepSign(m,n,'circular',1)));   
end

function test_dottest_matrix(seed)
   m = randi(100); n = randi(100);
   A = opMatrix(randn(m,n));
   B = opMatrix(randn(m,n));
   assertFalse(spot.utils.dottest(opBlockDiag(A,B)))
end

function test_dottest_extend(seed)
   p = randi(100); q = randi(100);
   % Check extensions greater than 2
   pext = p*(2+floor(rand));
   qext = q*(2+floor(rand));
   assertFalse(spot.utils.dottest(opExtend(p,q,pext,qext)))
   % Check extensions less than 1
   pext = p*floor(rand);
   qext = q*floor(rand);
   assertFalse(spot.utils.dottest(opExtend(p,q,pext,qext)))
end
