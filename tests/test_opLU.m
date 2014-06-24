function test_suite = test_opLU
%test_opLU  Unit tests for opLU.
initTestSuite;
end

function test_opLU_multiply

   rng('default');

   % Set up matrices and operators for problems
   A  = randn(5,5) + sqrt(-1) * randn(5,5);
   B  = opLU(A);
   x  = randn(5,1);

   % Check opLU
   assertElementsAlmostEqual(...
      A \ x  ,...
      B * x  );

end

function test_opLU_divide

   rng('default');

   % Set up matrices and operators for problems
   A  = randn(5,5) + sqrt(-1) * randn(5,5);
   B  = opLU(A);
   x  = randn(5,1);

   % Check opLU
   assertElementsAlmostEqual(...
      A * x  ,...
      B \ x  );

end

function test_opLU_double

   rng('default');

   % Set up matrices and operators for problems
   A  = randn(5,5) + sqrt(-1) * randn(5,5);
   B  = opLU(A);

   % Check opLU
   assertElementsAlmostEqual(inv(A), double(B));

end
