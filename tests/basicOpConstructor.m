function data = basicOpConstructor(opType, debug)

if (nargin < 2)
    debug = false;
end

basicOpData = basicTestsData();
maxMatrixSize = basicOpData.maxMatrixSize;
relativeTol = basicOpData.relativeTol;
seedFile = basicOpData.seedFile;

ST = dbstack;
if size(ST)<2
    fileName = ST(1).file;
    %testName = ST(1).file;
else
    fileName = ST(2).file;
    %testName = ST(2).name;
end

time = datestr(clock);
if debug
    [seed, state] = readSeed(seedFile, fileName);
else
    [seed, state] = readSeed(seedFile, fileName, time);
end

fid = fopen(seedFile);
if fid<0
    fid = fopen(seedFile, 'a');
    fprintf(fid, 'time\tfile name\trand seed\trandn state\n')
    %fprintf(fid, 'time\tfile name\ttest name\trand seed\trandn state\n')
else
    fclose(fid);
end

if isnan(seed)
    seed = rand('seed');
    state = randn('state');
    fid = fopen(seedFile, 'a');
    fprintf(fid, [time,'\t',fileName, '\t',... %testName, '\t', ...
        num2str(seed), '\t', num2str(state(1)), ';\t', num2str(state(2)), '\n']);
else
    rand('seed', seed);
    randn('state', state);
end

switch opType
    case 'Eye'
        A = opTypeConstr2Param(opType, maxMatrixSize);

    case 'Dirac'
        A = opTypeConstr1Param(opType, maxMatrixSize);

    case 'Zeros'
        A = opTypeConstr2Param(opType, maxMatrixSize);

    case 'Ones'
        A = opTypeConstr2Param(opType, maxMatrixSize);
        
    case 'Diag'
        m = randi(maxMatrixSize);
        d = randn(m);
        A = opDiag(d);

    case 'Window'
        disp('opWindow');
        
    case 'DCT'
        A = opTypeConstr1Param(opType, maxMatrixSize);

    case 'FFT'
        A = opTypeConstr2Param(opType, maxMatrixSize);
        
    case 'Haar'
        maxLevel = 5;
        m = 2^ceil(rand*log2(maxMatrixSize));
        n = 2^ceil(rand*log2(maxMatrixSize));
        l = ceil(rand*maxLevel);
        A = opHaar(m,n,l);
        
    case 'Hadamard'
        n = 2^ceil(rand*log2(maxMatrixSize));
        A = opHadamard(n);
        
    case 'Heaviside'
        A = opTypeConstr1Param(opType, maxMatrixSize);
        
    case 'Toeplitz'
        m = randi(maxMatrixSize);
        n = randi(maxMatrixSize);
        v1 = randi(maxMatrixSize);
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
        v_vect=randn(v,1);

        A = opToeplitz(m,n, v_vect);
        
    case 'ToepGauss'
        A = opTypeConstr2Param(opType, maxMatrixSize);
        
    case 'ToepSign'
        A = opTypeConstr2Param(opType, maxMatrixSize);

    otherwise
        A = eval(['op',opType,'()']);
end

data = struct('operator', A, 'relativeTol', relativeTol, 'operatorType', opType);

end

function A = opTypeConstr1Param(opType, maxMatrixSize)

n = randi(maxMatrixSize);
A = eval(['op',opType,'(',num2str(n),')']);

end

function A = opTypeConstr2Param(opType, maxMatrixSize)

m = randi(maxMatrixSize);
n = randi(maxMatrixSize);
A = eval(['op',opType,'(',num2str(m),',',num2str(n),')']);

end

function result = randi(n)
result = ceil(rand*n);
end

function [seed, state] = readSeed(seedFile, fileName, time)

fid = fopen(seedFile, 'r');
if fid < 0
    seed = NaN;
    state = NaN;
    return;
end

text = textscan(fid, '%s', 'delimiter', '\n');
text = text{1};
if numel(text)>1
    if nargin == 3
        curEntry = textscan(text{end}, '%s', 'delimiter', '\t');
        curEntry = curEntry{1};
        if (datecmp(curEntry{1}, time) && strcmp(curEntry{2}, fileName))
            seed = str2double(curEntry{3});
            state = [str2double(curEntry{4}); str2double(curEntry{5})];
            return;
        end
    else
        for i = numel(text):-1:1
            curEntry = textscan(text{i}, '%s', 'delimiter', '\t');
            curEntry = curEntry{1};
            if(strcmp(curEntry{2} , fileName))
                seed = str2double(curEntry{3});
                state = [str2double(curEntry{4}); str2double(curEntry{5})];
                return;
            end
        end
    end
end

seed = NaN;
state = NaN;
    
end

function result = datecmp (t1, t2, diff)

if nargin < 3
    diff = [0, 0, 0, 0, 0, 30];
end

t1v = datevec(t1);
t2v = datevec(t2);

result = true;
for i=1:numel(diff)
    result = result * (abs(t1v(i)-t2v(i)) <= diff(i));
end
end
