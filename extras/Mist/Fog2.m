classdef Fog2 < Mist
    %FOG Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (SetAccess = private)
        boys = {};
    end
    
    methods
        function op = Fog2(A,B)
            op          = op@Mist();
            %op.children = {A,B};
            op.boys     = {A,B};
            
        end
        
        function y = double(op)
            y = double(op.boys{1})*double(op.boys{2});
        end
        
        function y = mtimes(op,x)
            if isa(op,'Mist') && isa(x,'Mist') ||...
              ~isa(op,'Mist') && isa(x,'Mist')
                y = Fog2(op,x);
                
            elseif isa(op,'Mist')
                y = double(op)*x;
                
            else
                error('I dont know what youre doing');
            end
        end
    end
    
end

