function output = utest(op,k,verbose)
%TEST   Built-in unit tests for spot operators
%
%   By default it runs the dottest on the operator in question.
%   For overloading with extra tests
if nargin < 3, verbose = 0; end
if nargin < 2, k = 10; end
assertFalse(dottest(op,k,verbose));
assertTrue(op.xtratests);
output = 'PASSED!';
end