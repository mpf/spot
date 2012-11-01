function test_suite = test_opBernoulli
%testGaussian  Unit tests for the Gaussian operator
initTestSuite;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function seed = setup
   seed = rng('default');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  
function test_opBernoulli_mode01_against_rand(seed)
   m = 10; n = 5;

   rng(seed);  A1 = 2*(randn(m,n)<0)-1;
   rng(seed);  A2 = opBernoulli(m,n);
   rng(seed);  A3 = opBernoulli(m,n,0); % explicit
   rng(seed);  A4 = opBernoulli(m,n,1); % implicit

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
function test_opBernoulli_mode23(seed)
   m = 10; n = 5;

   rng(seed);  A1 = opBernoulli(m,n,2); % explicit
   rng(seed);  A2 = opBernoulli(m,n,3); % implicit

   assertElementsAlmostEqual( double(A1), double(A2) );
end
