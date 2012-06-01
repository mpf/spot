function output = utest(op,k,verbose)
%TEST   Built-in operator-specific unit tests
%
%   A.utest runs the dottest on the operator in question, as well as
%   operator specific tests overloaded in the operator level function,
%   xtratests.
%   By default, it runs the dottest 5 times.
%
%   For overloading with extra tests, simply overload the function
%   xtratests in the operator class file with the desired tests. xtratests 
%   must return true to indicate a pass.
%
%   eg.
%   function result = xtratests(op)
%
%       % Crazy amazing stuffs happen here
%       if(passed)
%           result = true;
%       else
%           result = false;
%       end
%   end


try
    addpath(fullfile(spot.path,'tests','xunit'))
catch ME
    error('Can''t find xunit toolbox.')
end

if nargin < 3, verbose = 0; end
if nargin < 2, k = 5; end
assertFalse(dottest(op,k,verbose));
assertTrue(op.xtratests);
output = 'PASSED!';
end