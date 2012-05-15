classdef Fog < Mist
    %FOG Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (SetAccess = private)
        boys = {};
    end
    
    methods
        function op = Fog(A,B)
            op          = op@Mist();
            op.children = {A,B};
            op.boys     = {A,B};
            whos 
            x = op.children;
            whos x
            y = op.boys;
            whos y
            
        end
        
        function y = double(op)
            y = double(op.boys{1})*double(op.boys{2});
        end
        
        function y = mtimes(op,x)
            if isa(x,'Mist')
                y = Fog(op,x);
                
            elseif isa(op,'Mist')
                y = op.boys{2}*x;
                y = op.boys{1}*y;
                
            else
                error('I dont know what youre doing');
            end
        end
    end
    
end

