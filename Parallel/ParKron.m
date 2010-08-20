%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function op = ParKron(A, B, x, mode)


assert( nargin > 2, 'Exactly three operators must be specified.')
if nargin == 3, mode = 1; end

if isa(A,'numeric')
    % A matrix input is immediately cast as opMatrix
    A = opMatrix(A);
elseif ~isa(A,'opSpot')
    error('One of the operators is not a valid input.')
end
if isa(B,'numeric')
    % A matrix input is immediately cast as opMatrix
    B = opMatrix(B);
elseif ~isa(B,'opSpot')
    error('One of the operators is not a valid input.')
end
assert( isa(x,'distributed') && size(x,2) == 1, ...
    'Please, use a vected distributed matrix')


[rB, cB] = size(B);
[rA, cA] = size(A);
%assert(length(x) == cA*cB, 'size of x does not agree with dimensions of operators')

if mode == 1
    spmd
        y = length(getLocalPart(x))/cB;
        assert( mod(y,1) == 0, ' x must be distributed along columns before vec')
        x = reshape(getLocalPart(x),cB,y);
        x = B * x;
        x = x.';
        part = codistributed.build(y, ...
            codistributor1d(2,codistributor1d.unsetPartition, [1,numlabs]));
        x = codistributed.build(x, codistributor1d(1,part,[cA,rB]));
        x = redistribute(x, codistributor1d(2));
        x = getLocalPart(x);
        x = A * x;
        x = x.';
        x = codistributed.build(x, codistributor1d(1, ...
            codistributor1d.unsetPartition,[rB,rA]));
        x = redistribute(x, codistributor1d(2));
    end
else
    spmd
        y = length(getLocalPart(x))/rB;
        assert( mod(y,1) == 0, ' x must be distributed along columns before vec')
        x = reshape(getLocalPart(x),rB,y);
        x = B' * x;
        x = x.';
        part = codistributed.build(y, ...
            codistributor1d(2,codistributor1d.unsetPartition, [1,numlabs]));
        x = codistributed.build(x, codistributor1d(1,part,[rA,cB]));
        x = redistribute(x, codistributor1d(2));
        x = getLocalPart(x);
        x = A' * x;
        x = x.';
        x = codistributed.build(x, codistributor1d(1, ...
            codistributor1d.unsetPartition,[cB,cA]));
        x = redistribute(x, codistributor1d(2));
    end
end
op = x(:);
end