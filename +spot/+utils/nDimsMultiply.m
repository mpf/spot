function y = nDimsMultiply(OP,xloc)
%NDIMSMULTIPLY  Multiplication across all dimensions higher than 2
%
%   y = nDimsMultiply(OP,x) multiplies OP with the the first and second
%   dimensions (slice) of the n-Dimensional array x across all dimensions 
%   3 to N recursively. OP can be a Spot operator or a numerical matrix.

	if ndims(xloc) == 2
		y = OP*xloc;
	else
		sizX = size(xloc);
		idX(1 : ndims(xloc) - 1) = {':'};
		for i = 1:sizX(end)
			y(idX{:},i) = nDimsMultiply(OP,xloc(idX{:},i));
		end
	end
end