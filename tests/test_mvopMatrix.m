function test_suite = test_mvopMatrix
%test_opMatrix  Unit tests for opMatrix.
initTestSuite;
end

function test_mvopMatrix_multiply
   
   randn('state',0);
   
   % Set up matrices and operators for problems
   A  = randn(2,2) + sqrt(-1) * randn(2,2);
   B  = opMatrix(A);
   xr = randn(2,2);
   xi = sqrt(-1) * randn(2,2);
   x  = xr + xi;

   % Check opMatrix
   assertEqual( A * x  ,...
                B * x  );
   assertEqual( A * xr ,...
                B * xr );
   assertEqual( A * xi ,...
                B * xi );

end

function test_mvopMatrix_divide
   
   randn('state',0);
   
   % Set up matrices and operators for problems
   A  = randn(2,2) + sqrt(-1) * randn(2,2);
   B  = opMatrix(A);
   xr = randn(2,4);
   xi = sqrt(-1) * randn(2,4);
   x  = xr + xi;

   % Check opMatrix
   assertElementsAlmostEqual(...
      A \ x  ,...
      B \ x  );
   assertElementsAlmostEqual(...
      A \ xr ,...
      B \ xr );
   assertElementsAlmostEqual(...
      A \ xi ,...
      B \ xi );
   
end
