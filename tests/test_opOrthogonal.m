function test_suite = test_opOrthogonal
%test_opOrthogonal  Unit tests for opOrthogonal and derivative operators
initTestSuite;
end

function test_opOrthogonal_divide
   
   n = 23; % whatever...
   
   Q = opDCT(n); b = Q.rrandn;
   assertEqual( Q\b, Q'*b )
   assertElementsAlmostEqual( svd(double(Q)), ones(size(Q,1),1) );

   Q = opDCT2(n); b = Q.rrandn;
   assertEqual( Q\b, Q'*b )
   assertElementsAlmostEqual( svd(double(Q)), ones(size(Q,1),1) );

   Q = opDFT(n);  b = Q.rrandn;
   assertEqual( Q\b, Q'*b )
   assertElementsAlmostEqual( svd(double(Q)), ones(size(Q,1),1) );
   
   Q = opDFT2(n);  b = Q.rrandn;
   assertEqual( Q\b, Q'*b )
   assertElementsAlmostEqual( svd(double(Q)), ones(size(Q,1),1) );

   Q = opDirac(n);  b = Q.rrandn;
   assertEqual( Q\b, Q'*b )
   assertElementsAlmostEqual( svd(double(Q)), ones(size(Q,1),1) );

   Q = opHaar(128);  b = Q.rrandn;
   assertEqual( Q\b, Q'*b )
   assertElementsAlmostEqual( svd(double(Q)), ones(size(Q,1),1) );
   
end
