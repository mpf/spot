function y = nDimsMultiply(OP,xloc)
%NDIMSMULTIPLY  Multiplication across all dimensions higher than 2
%
%   y = nDimsMultiply(OP,x) multiplies OP with the the first and second
%   dimensions (slice) of the n-Dimensional array x across all dimensions
%   3 to N recursively. OP can be a Spot operator or a numerical matrix.

% Preallocate y (Very important)
sy    = size(xloc);
sy(1) = size(OP,1);
y     = zeros(sy);

if ndims(xloc) <= 2
    
    if isempty(xloc)
        y = zeros(size(OP,1),0);
    else
        y = OP*xloc;
    end
else
    idX(1 : ndims(xloc) - 1) = {':'};
    SIZE = size(xloc);
    for i = 1:SIZE(end)
        y(idX{:},i) = spot.utils.nDimsMultiply(OP,xloc(idX{:},i));
    end
end

end