function test_opMatrix
%test_opMatrix  Unit tests for operator transpose

   seed = randn('state');
   
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
