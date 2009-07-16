function A = basicOpConstruct(basicOp, maxMatrixSize)
%basicOpConstruct(basicOp, maxMatrixSize) Constructor function for the
%basic operators. An operator of a random size (up to maxMatrixSize) is
%created.
switch basicOp

    case 'Eye'
        A = basicOpConstr2Param(basicOp, maxMatrixSize);

    case 'Dirac'
        A = basicOpConstr1Param(basicOp, maxMatrixSize);

    case 'Zeros'
        A = basicOpConstr2Param(basicOp, maxMatrixSize);

    case 'Ones'
        A = basicOpConstr2Param(basicOp, maxMatrixSize);
        
    case 'Diag'
        m = ceil(rand*maxMatrixSize);
        d = randn(m);
        
        try
            A = eval(['op',basicOp,'(d)']);
        catch ME
            fprintf('\nVector d: \n')
            disp(d);
            fprintf('\n');
            rethrow(ME);
        end

    case 'Window'
        disp('opWindow');
        
    case 'DCT'
        A = basicOpConstr1Param(basicOp, maxMatrixSize);

    case 'FFT'
        A = basicOpConstr2Param(basicOp, maxMatrixSize);
        
    case 'Haar'
        maxLevel = 5;
        m = 2^ceil(rand*log2(maxMatrixSize));
        n = 2^ceil(rand*log2(maxMatrixSize));
        l = ceil(rand*maxLevel);
        try
            A = eval(['op',basicOp,'(',num2str(m),',',num2str(n),',',num2str(l),')']);
        catch ME
            fprintf(['\n(m,n,l): (',num2str(m),',',num2str(n),',',num2str(l),')\n']);
            rethrow(ME);
        end
        
    case 'Hadamard'
        n = 2^ceil(rand*log2(maxMatrixSize));
        try
            A = eval(['op',basicOp,'(',num2str(n),')']);
        catch ME
            fprintf(['\nn: ',num2str(n),'\n']);
            rethrow(ME);
        end
        
    case 'Heaviside'
        A = basicOpConstr1Param(basicOp, maxMatrixSize);
        
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
        v_vect=randn(v,1);
                
        try
            A = eval(['op',basicOp,'(',num2str(m),',',num2str(n),',v_vect)']);
        catch ME
            fprintf(['\n(m,n,v): (',num2str(m),',',num2str(n),',',num2str(v),')\n']);
            fprintf('\nVector v: \n')
            disp(v_vect);
            fprintf('\n');
            rethrow(ME);
        end
        
    case 'ToepGauss'
        A = basicOpConstr2Param(basicOp, maxMatrixSize);
        
    case 'ToepSign'
        A = basicOpConstr2Param(basicOp, maxMatrixSize);

    otherwise
        A = eval(['op',basicOp,'()']);
end

end

function A = basicOpConstr1Param(basicOp, maxMatrixSize)

n = ceil(rand*maxMatrixSize);
try
    A = eval(['op',basicOp,'(',num2str(n),')']);
catch ME
    fprintf(['\nn: ',num2str(n),'\n']);
    rethrow(ME);
end

end

function A = basicOpConstr2Param(basicOp, maxMatrixSize)

m = ceil(rand*maxMatrixSize);
n = ceil(rand*maxMatrixSize);
try
    A = eval(['op',basicOp,'(',num2str(m),',',num2str(n),')']);
catch ME
    fprintf(['\n(m,n): (',num2str(m),',',num2str(n),')\n']);
    rethrow(ME);
end

end