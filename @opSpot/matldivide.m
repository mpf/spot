function x = matldivide(op,b)
%\  Matlab built-in left matrix divide

%   X = bimldivide(op,b) is Matlab's builtin backslash operator,
%   except that op is always a Spot operator, and b is always a numeric column
%   vector.

if isa(op, 'opSpot')
    A = op.double();
end
x = builtin('mldivide',A,b);

end

