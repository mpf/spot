function out = spottests(varargin)
%SPOTTESTS Run unit tests in Spot tests directory.
%   spottests runs all the test cases that can be found in the current directory
%   and summarizes the results in the Command Window.
%
%   Test cases can be found in the following places in the current directory:
%
%       * An M-file function whose name starts with "test" or "Test" that
%       returns no output arguments.
%
%       * An M-file function whose name starts with "test" or "Test" that
%       contains subfunction tests and uses the initTestSuite script to
%       return a TestSuite object.
%
%       * An M-file defining a subclass of TestCase.
%
%   runtests(dirname) runs all the test cases found in the specified directory.
%
%   runtests(mfilename) runs test cases found in the specified function or class
%   name. The function or class needs to be in the current directory or on the
%   MATLAB path.
%
%   runtests('mfilename:testname') runs the specific test case named 'testname'
%   found in the function or class 'name'.
%
%   Multiple directories or file names can be specified by passing multiple
%   names to runtests, as in runtests(name1, name2, ...). 
%
%   Examples
%   --------
%   Find and run all the test cases in the Spot test directory:
%
%       spottests
%
%   Find and run all the test cases contained in the M-file myfunc:
%
%       spottests myfunc
%
%   Find and run all the test cases contained in the TestCase subclass
%   MyTestCase:
%
%       spottests MyTestCase
%
%   Run the test case named 'testFeature' contained in the M-file myfunc:
%
%       spottests myfunc:testFeature
%
%   Run all the tests in a specific directory:
%
%       spottests c:\Work\MyProject\tests
%
%   Run all the tests in two directories:
%
%       spottests c:\Work\MyProject\tests c:\Work\Book\tests

%   06 Sep 2009 (Michael P. Friedlander): File originally belonged to xUnit
%   (see copyright below.) Renamed from "runtests" to "spottests" to avoid
%   conflict with "runtests" found in the xUnit toolbox.

%   Steven L. Eddins
%   Copyright 2009 The MathWorks, Inc.

% Make sure that xUnit is on the path.
if exist('TestSuite','file')
   % Relax. Found it.
else
   try
      addpath(fullfile(spot.path,'tests','xunit'))
   catch ME
      error('Can''t find xunit toolbox.')
   end
end
      
if nargin < 1
    suite = TestSuite.fromName(fullfile(spot.path,'tests'));
else
    name_list = getInputNames(varargin{:});
    if numel(name_list) == 1
        suite = TestSuite.fromName(name_list{1});
    else
        suite = TestSuite();
        for k = 1:numel(name_list)
            suite.add(TestSuite.fromName(name_list{k}));
        end
    end
end

did_pass = suite.run(spot.utils.SpotTestRunDisplay());

if nargout > 0
    out = did_pass;
end

function name_list = getInputNames(varargin)
name_list = {};
for k = 1:numel(varargin)
    name = varargin{k};
    if ~isempty(name) && (name(1) == '-')
        warning('runtests:unrecognizedOption', 'Unrecognized option: %s', name);
    else
        name_list{end+1} = name;
    end
end
