function test_suite = test_opiChol
%test_opiChol  Unit tests for opiChol.
initTestSuite;
end

function test_opiChol_multiply

   rng('default');

   % Set up matrices and operators for problems
   A = randn(5,5) + sqrt(-1) * randn(5,5);
   A = A * A';
   B = opiChol(A);
   opts.shape = 'lower';
   L = ichol(sparse(A), opts);
   x = randn(5,1);

   % Check opiChol
   assertElementsAlmostEqual(...
      L' \ (L \ x)  ,...
      B * x  );

end

function test_opiChol_divide

   rng('default');

   % Set up matrices and operators for problems
   A = randn(5,5) + sqrt(-1) * randn(5,5);
   A = A * A';
   B = opiChol(A);
   opts.shape = 'lower';
   L = ichol(sparse(A), opts);
   x = randn(5,1);

   % Check opiChol
   assertElementsAlmostEqual(...
      L * (L' * x)  ,...
      B \ x  );

end
