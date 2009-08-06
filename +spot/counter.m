classdef counter < handle
%counter  Counter class used to track no. of matrix-vector products.

%   Copyright 2009, Ewout van den Berg and Michael P. Friedlander
%   http://www.cs.ubc.ca/labs/scl/spot

   properties
      mode1=0 % count of products A *x
      mode2=0 % count of products A'*y
   end
   methods
      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
      function plus1(obj,mode)
         if mode == 1
            obj.mode1 = obj.mode1 + 1;
         elseif mode == 2
            obj.mode2 = obj.mode2 + 1;
         else
            error('Unrecognized mode.');
         end
      end % function plus1
   end % methods
end % classdef