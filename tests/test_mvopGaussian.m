function test_suite = test_mvopGaussian
%test_opGaussian  Unit tests for the Gaussian operator
initTestSuite;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function seed = setup
   randn('state',0);
   seed = randn('state');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  
function test_mvopGaussian_mode01_against_rand(seed)
   m = 10; n = 5;

   randn('state',seed);  A1 = randn(m,n);
   randn('state',seed);  A2 = opGaussian(m,n);
   randn('state',seed);  A3 = opGaussian(m,n,0); % explicit
   randn('state',seed);  A4 = opGaussian(m,n,1); % implicit

   x = randn(n,2);
   y = A1*x;

   assertEqual( y, A2*x );
   assertEqual( y, A3*x );
   assertEqual( y, A4*x );
   assertEqual( A1, double(A2) );
   assertEqual( A1, double(A3) );
   assertEqual( A1, double(A4) );
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function test_mvopGaussian_mode23(seed)
   m = 10; n = 5;

   randn('state',seed);  A1 = opGaussian(m,n,2); % explicit
   randn('state',seed);  A2 = opGaussian(m,n,3); % implicit

   assertElementsAlmostEqual( double(A1), double(A2) );
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function test_mvopGaussian_mode4(seed)
% Mode 4 produces orthog rows. Check that singular vals are all 1.
   randn('state',seed);
   m = 10; n = 10;  A = opGaussian(m,n,4); % explicit
   assertElementsAlmostEqual( ones(m,1), svd(double(A)) );

   m = 10; n = 21;  A = opGaussian(m,n,4); % explicit
   assertElementsAlmostEqual( ones(m,1), svd(double(A)) );

end
