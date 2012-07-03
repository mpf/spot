function test_sparsevecs
%test_sparsevecs  Unit tests on operator-(sparse)matrix products.

% All operators should work with sparse vectors. Some of the operators
% (should) internally do a full(x) before applying x. This script makes
% certain that's the case.

rng('default');

m = randi(100);
n = randi(100);

[A,xs,xf] = generate(opBernoulli(m,n));  assertEqual( full(A*xs), A*xf );
[A,xs,xf] = generate(opBinary(m,n));     assertEqual( full(A*xs), A*xf );
[A,xs,xf] = generate(opDCT(n));          assertEqual( full(A*xs), A*xf );
[A,xs,xf] = generate(opDCT2(m,n));       assertEqual( full(A*xs), A*xf );
[A,xs,xf] = generate(opDirac(n));        assertEqual( full(A*xs), A*xf );
[A,xs,xf] = generate(opEmpty(m,0));      assertEqual( full(A*xs), A*xf );
[A,xs,xf] = generate(opEye(n));          assertEqual( full(A*xs), A*xf );
[A,xs,xf] = generate(opDFT(n));          assertEqual( full(A*xs), A*xf );
[A,xs,xf] = generate(opDFT2(m,n));       assertEqual( full(A*xs), A*xf );
[A,xs,xf] = generate(opGaussian(m,n));   assertEqual( full(A*xs), A*xf );
[A,xs,xf] = generate(opHaar(64));        assertEqual( full(A*xs), A*xf );
[A,xs,xf] = generate(opHaar(64,5,1));    assertEqual( full(A*xs), A*xf );
[A,xs,xf] = generate(opHaar2(64,128));   assertEqual( full(A*xs), A*xf );
[A,xs,xf] = generate(opHadamard(256));   assertEqual( full(A*xs), A*xf );
[A,xs,xf] = generate(opHadamard(256,1)); assertEqual( full(A*xs), A*xf );
[A,xs,xf] = generate(opHeaviside(n));    assertEqual( full(A*xs), A*xf );
[A,xs,xf] = generate(opHeaviside(n,1));  assertEqual( full(A*xs), A*xf );
[A,xs,xf] = generate(opOnes(m,n));       assertEqual( full(A*xs), A*xf );

%[A,xs,xf] = generate(opSurfacelet([m,n],1));assertEqual( full(A*xs), A*xf );

[A,xs,xf] = generate(opToepGauss(m,n));             assertEqual( full(A*xs), A*xf );
[A,xs,xf] = generate(opToepGauss(m,n,'circular'));  assertEqual( full(A*xs), A*xf );
[A,xs,xf] = generate(opToepGauss(m,n,'toeplitz',1));assertEqual( full(A*xs), A*xf );
[A,xs,xf] = generate(opToepGauss(m,n,'circular',1));assertEqual( full(A*xs), A*xf );

[A,xs,xf] = generate(opToepSign(m,n));             assertEqual( full(A*xs), A*xf );
[A,xs,xf] = generate(opToepSign(m,n,'circular'));  assertEqual( full(A*xs), A*xf );
[A,xs,xf] = generate(opToepSign(m,n,'toeplitz',1));assertEqual( full(A*xs), A*xf );
[A,xs,xf] = generate(opToepSign(m,n,'circular',1));assertEqual( full(A*xs), A*xf );

end

function [A,xs,xf] = generate(A)
   [m,n] = size(A);
   xs = sprand(n,1,.1);
   if ~isreal(A)
      xs = xs + sqrt(-1)*sprandn(n,1,.1);
   end
   xf = full(xs);
end

   