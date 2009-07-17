function tests = buildBasicTests

data = basicTestsData();

maxMatrixSize = data.maxMatrixSize;
relativeTol = data.relativeTol;
basicOps = data.basicOperators;
basicOpTests = data.basicTests;

tests = cell(size(basicOps));

basicTests = '';
for j = 1:length(basicOpTests)
    curOpTest = basicOpTests{j};
    fileName = ['templates/test_', curOpTest, '.m'];
    fid = fopen(fileName, 'r');
    text = textscan(fid, '%s', 'delimiter', '\n');
    text = text{1};
    for i=1:numel(text)
        text_formatted = textFormat(text{i});
        basicTests = [basicTests, text_formatted, '\n'];
    end
    basicTests = [basicTests, '\n\n'];
end

for i = 1:length(basicOps)
    curBasicOp = basicOps{i};

    header = testSuiteHeader(curBasicOp);

    setup = testSuiteSetup(curBasicOp, maxMatrixSize, relativeTol);

    testSuite = [header, '\n\n', setup, '\n\n', basicTests];

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
    'end\n'];
end

function text = testSuiteSetup(basicOp, maxMatrixSize, relativeTol)
%basicOpConstruct(basicOp, maxMatrixSize, relativeTol) Constructor function for the
%basic operators. An operator of a random size (up to maxMatrixSize, relativeTol) is
%created.
switch basicOp

    case 'Eye'
        text = basicOpConstr2Param(basicOp, maxMatrixSize, relativeTol);

    case 'Dirac'
        text = basicOpConstr1Param(basicOp, maxMatrixSize, relativeTol);

    case 'Zeros'
        text = basicOpConstr2Param(basicOp, maxMatrixSize, relativeTol);

    case 'Ones'
        text = basicOpConstr2Param(basicOp, maxMatrixSize, relativeTol);

    case 'Diag'
        m = ceil(rand*maxMatrixSize);
        d = randn(m,1);

        d_text = num2str(d);
        d_vect = ['[', d_text(1,:)];
        for i=2:size(d_text,2)
            d_vect = [d_vect, ', ', d_text(i,:)];
        end
        d_vect = [d_vect, ']'];

        text = ...
            ['function data = setup\n'...
            '%%Calling the constructor for', basicOp, '.\n',...
            'd = ', d_vect, ';\n',...
            'data = struct(''operator'', op',basicOp,'(d), ',...
                '''relativeTol'', ', num2str(relativeTol),', ',...
                '''operatorType'', ''', basicOp,''');\n',...
            'A = op',basicOp,'(d);\n',...
            'end\n'];

    case 'Window'
        disp('opWindow');

    case 'DCT'
        text = basicOpConstr1Param(basicOp, maxMatrixSize, relativeTol);

    case 'FFT'
        text = basicOpConstr2Param(basicOp, maxMatrixSize, relativeTol);

    case 'Haar'
        maxLevel = 5;
        m = 2^ceil(rand*log2(maxMatrixSize));
        n = 2^ceil(rand*log2(maxMatrixSize));
        l = ceil(rand*maxLevel);
        text = ...
            ['function data = setup\n'...
            '%%Calling the constructor for', basicOp, '.\n',...
            'data = struct(''operator'', op',basicOp,'(',num2str(m),',',num2str(n),',',num2str(l),'), ',...
                '''relativeTol'', ', num2str(relativeTol),', ',...
                '''operatorType'', ''', basicOp,''');\n',...
            'end\n'];

    case 'Hadamard'
        n = 2^ceil(rand*log2(maxMatrixSize));
        text = ...
            ['function data = setup\n'...
            '%%Calling the constructor for', basicOp, '.\n',...
            'data = struct(''operator'', op',basicOp,'(',num2str(n),'), ',...
                '''relativeTol'', ', num2str(relativeTol),', ',...
                '''operatorType'', ''', basicOp,''');\n',...
            'end\n'];

    case 'Heaviside'
        text = basicOpConstr1Param(basicOp, maxMatrixSize, relativeTol);

    case 'Toeplitz'
        m = ceil(rand*maxMatrixSize);
        n = ceil(rand*maxMatrixSize);
        v1 = ceil(rand*maxMatrixSize);
        v2 = m+n-1;
        v3 = max(m,n);
        v = rand;
        if v<1/3
            v=v1;
        elseif v>2/3
            v=v3;
        else
            v=v2;
        end
        v=randn(v,1);

        v_text = num2str(v);
        v_vect = ['[', v_text(1,:)];
        for i=2:size(v_text,2)
            v_vect = [v_vect,', ', v_text(i,:)];
        end
        v_vect = [v_vect, ']'];

        text = ...
            ['function data = setup\n'...
            '%%Calling the constructor for', basicOp, '.\n',...
            'v = ', v_vect, ';\n',...
            'data = struct(''operator'', op',basicOp,'(',num2str(m),',',num2str(n),', v), ',...
                '''relativeTol'', ', num2str(relativeTol),', ',...
                '''operatorType'', ''', basicOp,''');\n',...
            'end\n'];

    case 'ToepGauss'
        text = basicOpConstr2Param(basicOp, maxMatrixSize, relativeTol);

    case 'ToepSign'
        text = basicOpConstr2Param(basicOp, maxMatrixSize, relativeTol);

    otherwise
        text = eval(['op',basicOp,'()']);
end

end

function text = basicOpConstr1Param(basicOp, maxMatrixSize, relativeTol)

n = ceil(rand*maxMatrixSize);

text = ...
    ['function data = setup\n'...
    '%%Calling the constructor for', basicOp, '.\n',...
    'data = struct(''operator'', op',basicOp,'(',num2str(n),'), ',...
    '''relativeTol'', ', num2str(relativeTol),', ',...
    '''operatorType'', ''', basicOp,''');\n',...
    'end\n'];

end

function text = basicOpConstr2Param(basicOp, maxMatrixSize, relativeTol)

m = ceil(rand*maxMatrixSize);
n = ceil(rand*maxMatrixSize);

text = ...
    ['function data = setup\n'...
    '%%Calling the constructor for', basicOp, '.\n',...
    'data = struct(''operator'', op',basicOp,'(',num2str(m),',',num2str(n),'), ',...
        '''relativeTol'', ', num2str(relativeTol),', ',...
        '''operatorType'', ''', basicOp,''');\n',...
    'end\n'];

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