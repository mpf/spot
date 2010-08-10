function OUT = PTranspose(Data, dim1, dim2, dist)
%PTranspose - to transpose distributed nd-arrays. dim1 and dim2 specify the
%dimensions to be transposed, and the optional dist specifies the dimension
%from the original array for the output to be distributed along. If dist
%isn't provided, the answer is distributed along its last dimension.
%ex:  A(:,:,1) = 1  2    A(:,:,2) = 5  6 
%                3  4               7  8
% PTranspose(A,1,3,1)
%  
% ans(:,:,1) = 1  2     ans(:,:,2) = 3  4
%              5  6                  7  8
% dustributed along 3rd dimension

%TO DO - add comments!!
%TO DO - do transpose in place
error(nargchk(3, 4, nargin))
if nargin == 3,    dist = -1;   end
if numlabs ~= 1
    error('This function is not meant to be called from an spmd block')
end
if ~isa(Data, 'distributed')
    error('Input must be distributed')
end
if ~isnumeric(dim1) || ~isnumeric(dim2) || length(dim1) ~= 1 ...
        || length(dim2)~=1 || dim1 > ndims(Data) || dim2 > ndims(Data)
    error('Transpose dimensions must be individual dimensions of Data')
end
if ~isnumeric(dist) || length(dist) ~= 1 || dist > ndims(Data)
    error('Distribution dimension must be an individual dimension of Data')
end

%figure out the dimensions of the data and rearrange them to the transposed
%dimensions
dims = size(Data);
temp = dims(dim1);
dims(dim1) = dims(dim2);
dims(dim2) = temp;

%setup the arrangement of the transposed dimensions
perm = 1:ndims(Data);
perm(dim1) = dim2;
perm(dim2) = dim1;

spmd
    codistr = getCodistributor(Data);
    dimdist = codistr.Dimension;
    
    %incase the distributed dimension is involved in the transpose
    dimdist = perm(dimdist);
    if dist > 0,   dist = perm(dist);
    %incase dist wasn't specified
    else    dist = ndims(Data);   end
    
    %do the transpose locally on each lab and then build the codistributed
    %array again
    d = permute(getLocalPart(Data), perm);
    codistr = codistributor1d( dimdist, ...
        codistributor1d.unsetPartition, dims);
    Data = codistributed.build(d, codistr);
    
    %if the dimension of distribution changed
    if dimdist ~= dist
        codistr = codistributor1d(dist);
        Data = redistribute( Data, codistr);
    end
end
OUT = Data;

end