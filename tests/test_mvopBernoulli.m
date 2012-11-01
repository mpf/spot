function test_suite = test_mvopBernoulli
%testGaussian  Unit tests for the Gaussian operator
initTestSuite;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function seed = setup
   seed = randn('state');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  
function test_mvopBernoulli_mode01_against_rand(seed)
   m = 10; n = 5;

   randn('state',seed);  A1 = 2*(randn(m,n)<0)-1;
   randn('state',seed);  A2 = opBernoulli(m,n);
   randn('state',seed);  A3 = opBernoulli(m,n,0); % explicit
   randn('state',seed);  A4 = opBernoulli(m,n,1); % implicit

   x = randn(n,2);
   y = A1 *x;
   z = A1'*y;
   
   assertElementsAlmostEqual(  y , A2 *x  );
   assertElementsAlmostEqual(  y , A3 *x  );
   assertElementsAlmostEqual(  y , A4 *x  );
   assertElementsAlmostEqual(  z , A2'*y  );
   assertElementsAlmostEqual(  z , A3'*y  );
   assertElementsAlmostEqual(  z , A4'*y  );
   assertElementsAlmostEqual( A1 , double(A2) );
   assertElementsAlmostEqual( A1 , double(A3) );
   assertElementsAlmostEqual( A1 , double(A4) );
   assertElementsAlmostEqual( A1', double(A2') );
   assertElementsAlmostEqual( A1', double(A3') );
   assertElementsAlmostEqual( A1', double(A4') );
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function test_mvopBernoulli_mode23(seed)
   m = 10; n = 5;

   randn('state',seed);  A1 = opBernoulli(m,n,2); % explicit
   randn('state',seed);  A2 = opBernoulli(m,n,3); % implicit

   assertElementsAlmostEqual( double(A1), double(A2) );
end
