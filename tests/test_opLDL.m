function test_suite = test_opLDL
%test_opLDL  Unit tests for opLDL.
initTestSuite;
end

function test_opLDL_multiply

   rng('default');

   % Set up matrices and operators for problems
   A  = randn(5,5);
   A  = tril(A) + tril(A,-1)';
   B  = opLDL(A);
   x  = randn(5,1);

   % Check opLDL
   assertElementsAlmostEqual(...
      A \ x  ,...
      B * x  );

end

function test_opLDL_divide

   rng('default');

   % Set up matrices and operators for problems
   A  = randn(5,5);
   A  = tril(A) + tril(A,-1)';
   B  = opLDL(A);
   x  = randn(5,1);

   % Check opLDL
   assertElementsAlmostEqual(...
      A * x  ,...
      B \ x  );

end

function test_opLDL_double

   rng('default');

   % Set up matrices and operators for problems
   A  = randn(5,5);
   A  = tril(A) + tril(A,-1)';
   B  = opLDL(A);

   % Check opLDL
   assertElementsAlmostEqual(inv(A), double(B));

end
