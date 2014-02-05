function test_suite = test_opiLU
%test_opiLU  Unit tests for opiLU.
initTestSuite;
end

function test_opiLU_multiply

   rng('default');

   % Set up matrices and operators for problems
   A  = randn(5,5) + sqrt(-1) * randn(5,5);
   B  = opiLU(A);
   [L,U] = ilu(sparse(A));
   x  = randn(5,1);

   % Check opiLU
   assertElementsAlmostEqual(...
      U \ (L \ x)  ,...
      B * x  );

end

function test_opiLU_divide

   rng('default');

   % Set up matrices and operators for problems
   A  = randn(5,5) + sqrt(-1) * randn(5,5);
   B  = opiLU(A);
   [L,U] = ilu(sparse(A));
   x  = randn(5,1);

   % Check opiLU
   assertElementsAlmostEqual(...
      L * (U * x)  ,...
      B \ x  );

end
