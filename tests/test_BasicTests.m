function test_suite = test_BasicTests
%a number of basic tests for a list of basic operators
    initTestSuite;
end

function test_BasicOperators_Using_BasicTests

maxMatrixSize = 100;
relative_tol = 1e-14;

lists = opsBasic();
basicOps = lists.basicOperators;
basicOpTests = lists.basicTests;
tolNeeded = lists.tol;

for i = 1:length(basicOps)
    curBasicOp = basicOps{i};
    A = basicOpConstruct(curBasicOp, maxMatrixSize);
    for j = 1:length(basicOpTests)
        if tolNeeded(j)
            test = strcat('bt',basicOpTests{j},'(A, relative_tol)');
        else
            test = strcat('bt',basicOpTests{j},'(A)');
        end
        eval(test);
    end
end

end