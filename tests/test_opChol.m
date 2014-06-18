function test_suite = test_opChol
%test_opChol  Unit tests for opChol.
initTestSuite;
end

function test_opChol_multiply

   rng('default');

   % Set up matrices and operators for problems
   A  = randn(5,5) + sqrt(-1) * randn(5,5);
   A  = A * A';
   B  = opChol(A);
   x  = randn(5,1);

   % Check opChol
   assertElementsAlmostEqual(...
      A \ x  ,...
      B * x  );

end

function test_opChol_divide

   rng('default');

   % Set up matrices and operators for problems
   A  = randn(5,5) + sqrt(-1) * randn(5,5);
   A  = A * A';
   B  = opChol(A);
   x  = randn(5,1);

   % Check opChol
   assertElementsAlmostEqual(...
      A * x  ,...
      B \ x  );

end

function test_opChol_double

   rng('default');

   % Set up matrices and operators for problems
   A  = randn(5,5) + sqrt(-1) * randn(5,5);
   A  = A * A';
   B  = opChol(A);

   % Check opChol
   assertElementsAlmostEqual(inv(A), double(B));

end
