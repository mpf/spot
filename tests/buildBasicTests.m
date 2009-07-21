function tests = buildBasicTests

data = basicTestsData();

%maxMatrixSize = data.maxMatrixSize;
%relativeTol = data.relativeTol;
basicOps = data.basicOperators;
basicOpTests = data.basicTests;

tests = cell(size(basicOps));

for i = 1:length(basicOps)
    curBasicOp = basicOps{i};

    header = testSuiteHeader(curBasicOp);

    basicTests = '';
    for j = 1:length(basicOpTests)
        curOpTest = basicOpTests{j};
        fileName = ['templates/test_', curOpTest, '.m'];
        fid = fopen(fileName, 'r');
        text = textscan(fid, '%s', 'delimiter', '\n');
        text = text{1};
        text{1} = [text{1}(1:13), '_op', curBasicOp, text{1}(14:end)];
        for k=1:numel(text)
            text_formatted = textFormat(text{k});
            basicTests = [basicTests, text_formatted, '\n'];
        end
        basicTests = [basicTests, '\n\n'];
    end

    testSuite = [header, '\n\n', basicTests];

    fileName = ['test_basic_op', curBasicOp,'.m'];
    fid = fopen(fileName, 'w');
    fprintf(fid, testSuite);
    fclose(fid);
    tests{i} = fileName(1:end-2);
end

end

function text = testSuiteHeader(basicOp)
text = ...
    ['function test_suite = test_op', basicOp, '\n'...
    '%%test', basicOp, '  Unit tests for the Gaussian operator\n',...
    'initTestSuite;\n',...
    'end\n\n',...
    'function data = setup\n',...
    '%%Calling the constructor for ',basicOp,'.\n',...
    'ST = dbstack;\n',...
    'fileName = ST(1).file;\n',...
    'opType = fileName(14:end-2);\n',...
    'debug = false;\n\n',...
    'data = basicOpConstructor(opType, debug);\n',...
    'end'];

end

function result = textFormat(input)

result=input;
correctedChar=0;
for i=1:size(input)
    if input(i)=='%'
        result=[result(1:i+correctedChar), '%', input(i+1:end)];
        correctedChar=correctedChar+1;
    end
end

end