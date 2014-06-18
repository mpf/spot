function test_suite = test_opHermitian
%test_opHermitian  Unit tests for opHermitian.
initTestSuite;
end

function test_opHermitian_multiply

   rng('default');

   % Set up matrices and operators for problems
   A  = randn(5,5) + sqrt(-1) * randn(5,5);
   A  = A + A';
   B  = opHermitian(tril(A));
   xr = randn(5,1);
   xi = sqrt(-1) * randn(5,1);
   x  = xr + xi;

   % Check opHermitian
   assertElementsAlmostEqual(...
      A * x  ,...
      B * x  );
   assertElementsAlmostEqual(...
      A * xr ,...
      B * xr );
   assertElementsAlmostEqual(...
      A * xi ,...
      B * xi );

end

function test_opHermitian_divide

   rng('default');

   % Set up matrices and operators for problems
   A  = randn(5,5) + sqrt(-1) * randn(5,5);
   A  = A + A';
   B  = opHermitian(tril(A));
   xr = randn(5,1);
   xi = sqrt(-1) * randn(5,1);
   x  = xr + xi;

   % Check opHermitian
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

function test_opHermitian_double

   rng('default');

   % Set up matrices and operators for problems
   A  = randn(5,5) + sqrt(-1) * randn(5,5);
   A  = A + A';
   B  = opHermitian(tril(A));

   % Check opHermitian
   assertEqual(A, double(B));

end
