classdef Fog4 < Mist2
    %FOG Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (SetAccess = private)
        boys = {};
    end
    
    methods
        function op = Fog4(A,B)
            op          = op@Mist2();
            op.boys     = {A,B};
            
        end
        
        function y = double(op)
            y = double(op.boys{1})*double(op.boys{2});
        end
        
        function y = mtimes(op,x)
            if isa(op,'Mist2') && isa(x,'Mist2') ||...
              ~isa(op,'Mist2') && isa(x,'Mist2')
                y = Fog4(op,x);
                
            elseif isa(op,'Mist2')
                y = double(op)*x;
                
            else
                error('I dont know what youre doing');
            end
        end
    end
    
end

