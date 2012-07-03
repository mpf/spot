function test_suite = test_opBinary
%testGaussian  Unit tests for the Gaussian operator
initTestSuite;
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function seed = setup
   seed = rng('default');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  
function test_opBinary_against_randn(seed)
   m = randi(100); n = randi(100);

   rng(seed);  A1 = double(randn(m,n)<0);
   rng(seed);  A2 = opBinary(m,n);
   rng(seed);  A3 = opBinary(m,n,0); % explicit
   rng(seed);  A4 = opBinary(m,n,1); % implicit

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
