function test_normest
%test_normest  Unit tests for normest

   rng('default');
   tol = 1e-6;
   
   % Square real matrices
   m = 13; n = 13;
   A = randn(m,n);
   B = opMatrix(A);
   checkequal(A,B);

   % Square complex matrices
   m = 13; n = 13;
   A = randn(m,n) + 1i*randn(m,n);
   B = opMatrix(A);
   checkequal(A,B);
   
   % tall matrices
   m = 13; n = 10;
   A = randn(m,n) + 1i*randn(m,n);
   B = opMatrix(A);
   checkequal(A,B);  
   
   % wide matrices
   m = 10; n = 13;
   A = randn(m,n) + 1i*randn(m,n);
   B = opMatrix(A);
   checkequal(A,B);
   
   % "no column" matrices
   m = 0; n = 13;
   A = randn(m,n) + 1i*randn(m,n);
   B = opMatrix(A);
   checkequal(A,B);
   
   % "no row" matrices
   m = 13; n = 0;
   A = randn(m,n) + 1i*randn(m,n);
   B = opMatrix(A);
   checkequal(A,B);
   
   % Zero matrix
   m = 0; n = 0;
   A = randn(m,n) + 1i*randn(m,n);
   B = opMatrix(A);
   checkequal(A,B);

   % Empty matrix
   A = opEmpty(13,0);
   assertEqual(normest(A),0);
   A = opEmpty(0,13);
   assertEqual(normest(A),0);

   % Nested function
   function checkequal(A,B)
      assertElementsAlmostEqual(normest(A ),normest(B ),'relative',tol,tol);
      assertElementsAlmostEqual(normest(A'),normest(B'),'relative',tol,tol);
   end

end

