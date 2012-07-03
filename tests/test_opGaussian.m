function test_suite = test_opGaussian
%test_opGaussian  Unit tests for the Gaussian operator
initTestSuite;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function seed = setup
   seed = rng('default');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  
function test_opGaussian_mode01_against_rand(seed)
   m = 10; n = 5;

   rng(seed);  A1 = randn(m,n);
   rng(seed);  A2 = opGaussian(m,n);
   rng(seed);  A3 = opGaussian(m,n,0); % explicit
   rng(seed);  A4 = opGaussian(m,n,1); % implicit

   x = randn(n,1);
   y = A1*x;

   assertEqual( y, A2*x );
   assertEqual( y, A3*x );
   assertEqual( y, A4*x );
   assertEqual( A1, double(A2) );
   assertEqual( A1, double(A3) );
   assertEqual( A1, double(A4) );
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function test_opGaussian_mode23(seed)
   m = 10; n = 5;

   rng(seed);  A1 = opGaussian(m,n,2); % explicit
   rng(seed);  A2 = opGaussian(m,n,3); % implicit

   assertElementsAlmostEqual( double(A1), double(A2) );
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function test_opGaussian_mode4(seed)
% Mode 4 produces orthog rows. Check that singular vals are all 1.
   rng(seed);
   m = 10; n = 10;  A = opGaussian(m,n,4); % explicit
   assertElementsAlmostEqual( ones(m,1), svd(double(A)) );

   m = 10; n = 21;  A = opGaussian(m,n,4); % explicit
   assertElementsAlmostEqual( ones(m,1), svd(double(A)) );

end
