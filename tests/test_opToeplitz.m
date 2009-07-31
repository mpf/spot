function test_suite = test_opToeplitz
initTestSuite;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  
function test_opToeplitz_circular_real
   A1 = toeplitz([1,5:-1:2],[1:5]);
   A2 = opToeplitz(1:5);

   assertElementsAlmostEqual( A1, double(A2) );
   assertElementsAlmostEqual( A1', double(A2') );
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  
function test_opToeplitz_circular_real_scaled
   A1 = toeplitz([1,5:-1:2],[1:5]);
   A1 = A1 * spdiags(1./sqrt(sum(A1.^2)'),0,5,5);
   A2 = opToeplitz(1:5,1);

   assertElementsAlmostEqual( A1, double(A2) );
   assertElementsAlmostEqual( A1', double(A2') );
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  
function test_opToeplitz_circular_complex
   A1 = toeplitz([1,5:-1:2]+sqrt(-1)*[3,7:-1:4],[1:5]+sqrt(-1)*[3:7]);
   A2 = opToeplitz([1:5] + sqrt(-1)*[3:7]);
   
   assertElementsAlmostEqual( A1, double(A2) );
   assertElementsAlmostEqual( A1', double(A2') );
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  
function test_opToeplitz_circular_complex_scaled
   A1 = toeplitz([1,5:-1:2]+sqrt(-1)*[3,7:-1:4],[1:5]+sqrt(-1)*[3:7]);
   A1 = A1 * spdiags(1./sqrt(sum(abs(A1).^2)'),0,5,5);
   A2 = opToeplitz([1:5] + sqrt(-1)*[3:7],1);

   assertElementsAlmostEqual( A1, double(A2) );
   assertElementsAlmostEqual( A1', double(A2') );
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  
function test_opToeplitz_symmetric_real
   A1 = toeplitz(1:5);
   A2 = opToeplitz(1:5,[]);

   assertElementsAlmostEqual( A1, double(A2) );
   assertElementsAlmostEqual( A1', double(A2') );
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  
function test_opToeplitz_symmetric_real_scaled
   A1 = toeplitz(1:5);
   A1 = A1 * spdiags(1./sqrt(sum(A1.^2)'),0,5,5);
   A2 = opToeplitz(1:5,[],1);

   assertElementsAlmostEqual( A1, double(A2) );
   assertElementsAlmostEqual( A1', double(A2') );
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  
function test_opToeplitz_symmetric_complex
   A1 = toeplitz([1:5] + sqrt(-1)*[6:10]);
   A2 = opToeplitz([],[1:5] + sqrt(-1)*[6:10]);

   assertElementsAlmostEqual( A1, double(A2) );
   assertElementsAlmostEqual( A1', double(A2') );
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  
function test_opToeplitz_symmetric_compex_scaled
   A1 = toeplitz([1:5] + sqrt(-1)*[6:10]);
   A1 = A1 * spdiags(1./sqrt(sum(abs(A1).^2)'),0,5,5);
   A2 = opToeplitz([],[1:5] + sqrt(-1)*[6:10],1);

   assertElementsAlmostEqual( A1, double(A2) );
   assertElementsAlmostEqual( A1', double(A2') );
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  
function test_opToeplitz_real
   c = 1:5;
   r = 6:12;
   r(1) = c(1);
   
   A1 = toeplitz(c,r);
   A2 = opToeplitz(c,r);

   assertElementsAlmostEqual( A1, double(A2) );
   assertElementsAlmostEqual( A1', double(A2') );
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  
function test_opToeplitz_real_scaled
   c = 1:5;
   r = 6:12;
   r(1) = c(1);
   
   A1 = toeplitz(c,r);
   A1 = A1 * spdiags(1./sqrt(sum(A1.^2)'),0,7,7);
   A2 = opToeplitz(c,r,1);

   assertElementsAlmostEqual( A1, double(A2) );
   assertElementsAlmostEqual( A1', double(A2') );
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  
function test_opToeplitz_complex
   c = [1:5] + sqrt(-1)*[6:10];
   r = [6:12]+sqrt(-1)*[8:14];
   r(1) = c(1);

   A1 = toeplitz(c,r);
   A2 = opToeplitz(c,r);

   assertElementsAlmostEqual( A1, double(A2) );
   assertElementsAlmostEqual( A1', double(A2') );
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  
function test_opToeplitz_compex_scaled
   c = [1:5] + sqrt(-1)*[6:10];
   r = [6:12]+sqrt(-1)*[8:14];
   r(1) = c(1);

   A1 = toeplitz(c,r);
   A1 = A1 * spdiags(1./sqrt(sum(abs(A1).^2)'),0,7,7);
   A2 = opToeplitz(c,r,1);

   assertElementsAlmostEqual( A1, double(A2) );
   assertElementsAlmostEqual( A1', double(A2') );
end
