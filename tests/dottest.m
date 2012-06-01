function status = dottest(A,k,verbose)
%dottest  Apply the "dot-test" to an operator.
%
%   dottest(A) generates random vectors X and Y (from the domain and range
%   of A), and verifies that (A*X)'*Y = X'*(A'*Y) within a tolerance of
%   1E-10. This can help detect errors in the operator; it canot be used to
%   guarantee correctness. The function returns false when the test
%   succeeded and true if it failed.
%
%   dottest(A,K) applies the dottest K times. (Default K is 100).
%
%   dottest(A,K,VERBOSE), with VERBOSE ~= 0, will print some
%   diagnostic output.

%   Copyright 2008-2009, Ewout van den Berg and Michael P. Friedlander
%   http://www.cs.ubc.ca/labs/scl/spot

% Set default parameters
if nargin < 2, k = 100; end
if nargin < 3, verbose = 0; end

% Initialize
tol    = sqrt(eps);
err    = 0;
kpass  = 0;

if verbose
   fprintf('Performing dot test on operator: %s\n', char(A));
end

Ratio = [inf,0];
for i=1:k
    x   = A.drandn;
    y   = A.rrandn;
    z1  = (A*x)' * y;
    z2  = x' * (A'*y);
    err = max( err, abs(z1 - z2) );
    if err < tol,
       kpass = kpass + 1;
    else
       ratio = abs(z1) / abs(z2);
       if ratio < Ratio(1), Ratio(1) = ratio; end;
       if ratio > Ratio(2), Ratio(2) = ratio; end;
    end
end

if verbose
   if kpass < k
      fprintf('FAILED on %d out of %d tests\n', k-kpass, k);
      fprintf('%8s maximum absolute difference of %13.9e\n','',err);
      fprintf('%8s ratio between %13.9e and %13.9e\n', ...
                '',Ratio(1),Ratio(2));
   else
      fprintf('PASSED!\n');
   end
end

status = kpass == 0;
