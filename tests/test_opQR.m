function test_suite = test_opQR
%test_opQR  Unit tests for opQR.
initTestSuite;
end

function test_opQR_multiply_under

   rng('default');

   % Set up matrices and operators for problems
   A = randn(3,5) + sqrt(-1) * randn(3,5);
   B = opQR(A);
   x = randn(3,1) + sqrt(-1) * randn(3,1);

   % Check opQR
   assertElementsAlmostEqual( A * B * x  , x  );

end

function test_opQR_multiply_over

   rng('default');

   % Set up matrices and operators for problems
   A = randn(5,3) + sqrt(-1) * randn(5,3);
   B = opQR(A);
   x = randn(5,1) + sqrt(-1) * randn(5,1);

   % Check opQR
   assertElementsAlmostEqual((A'*A)\(A'*x), B * x );

end

function test_opQR_divide_under

   rng('default');

   % Set up matrices and operators for problems
   A = randn(3,5) + sqrt(-1) * randn(3,5);
   B = opQR(A);
   x = randn(5,1) + sqrt(-1) * randn(5,1);

   % Check opQR
   assertElementsAlmostEqual( A * x  , B \ x  );

end

function test_opQR_divide_over

   rng('default');

   % Set up matrices and operators for problems
   A = randn(5,3) + sqrt(-1) * randn(5,3);
   B = opQR(A);
   x = randn(3,1) + sqrt(-1) * randn(3,1);

   % Check opQR
   assertElementsAlmostEqual( A * x  , B \ x  );

end
