classdef Fog < Mist
    %FOG Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (SetAccess = private)
        operators = {};
    end
    
    methods
        function op = Fog(A,B)
            op          = op@Mist();
            op.children = {A,B};
            op.operators     = {A,B};
            children = op.children;
            operators = op.operators;
            whos
            
        end
        
        function y = double(op)
            y = double(op.operators{1})*double(op.operators{2});
        end
        
        function y = mtimes(op,x)
            if isa(x,'Mist')
                y = Fog(op,x);
                
            elseif isa(op,'Mist')
                y = op.operators{2}*x;
                y = op.operators{1}*y;
                
            else
                error('I dont know what youre doing');
            end
        end
    end
    
end

