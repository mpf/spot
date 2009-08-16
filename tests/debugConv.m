function y = debugConv(f,g,offset,mode)
% This function implements a debug version of the regular,
% cyclic, and truncated convolution operator for 1D and 2D
% signals.

switch lower(mode)
 case {'cyclic'}
    cyclic = true; truncated = false;
    
 case {'truncated'}
    cyclic = false; truncated = true;
    
 case {'default','regular',''}
    cyclic = false; truncated = false;
    
 otherwise
    error('Mode parameter must be one of ''regular'', ''cyclic'', or ''truncated''.');
end


if (size(f,2) == 1) && (size(g,2) == 1)
   % ========= One-dimensional case =========
   offset = offset(1);
   
   if cyclic
      % Fold or zero-pad g
      if length(g) > length(f)
         g = [g; zeros(rem(length(f)-rem(length(g),length(f)),length(f)),1)];
         g = sum(reshape(g,length(f),length(g)/length(f)),2);
      else
         g = [g; zeros(length(f)-length(g),1)];
      end
      
      % Shift to offset
      offset = rem(rem(offset-1,length(f)) + length(f),length(f))+1;
      g = [g(offset:end);g(1:offset-1)];

      % Compute convolution
      y = zeros(length(f),1);
      for i=1:length(f)
         y = y + f(i) * g;
         g = [g(end);g(1:end-1)];
      end
   else
      % Add padding when offset lies outside range
      if offset < 1
         g = [zeros(1-offset,1); g];
         offset = 1;
      end
      if offset > length(g)
         g = [g; zeros(offset-length(g),1)];
      end

      % Compute convolution
      y = zeros(length(f)+length(g)-1,1);
      n = length(g);
      for i=1:length(f)
         y(i:i+n-1) = y(i:i+n-1) + f(i) * g;
      end
      
      % Truncate result if needed
      if truncated
        y = y(offset:offset+length(f)-1);
      end
   end
   
else
   % ========= Two-dimensional case =========
   offset = offset(1:2);

   if cyclic
      % Fold and zero-pad g
      newg = zeros(size(f));
      for i=0:ceil(size(g,1)/size(f,1))-1
        idx1 = 1:min(size(f,1),size(g,1)-i*size(f,1));
        for j=0:ceil(size(g,2)/size(f,2))-1
           idx2 = 1:min(size(f,2),size(g,2)-j*size(f,2));
           newg(idx1,idx2) = newg(idx1,idx2) + g(i*size(f,1)+idx1,j*size(f,2)+idx2);
        end
      end
      g = newg;
      
      % Shift to offset
      offset(1) = rem(rem(offset(1)-1,size(f,1)) + size(f,1),size(f,1))+1;
      offset(2) = rem(rem(offset(2)-1,size(f,2)) + size(f,2),size(f,2))+1;
      g = [g(offset(1):end,:); g(1:offset(1)-1,:)];
      g = [g(:,offset(2):end), g(:,1:offset(2)-1)];
      
      % Compute convolution
      y = zeros(size(f));
      for i=1:size(f,1)
         for j=1:size(f,2)
            y = y + f(i,j) * g;
            g = [g(:,end), g(:,1:end-1)];
         end
         g = [g(end,:); g(1:end-1,:)];
      end
   else
      % Add padding when offset lies outside range
      if offset(1) < 1
         g = [zeros(1-offset(1),size(g,2)); g];
         offset(1) = 1;
      end
      if offset(1) > size(g,1)
         g = [g; zeros(offset(1)-size(g,1),size(g,2))];
      end
      if offset(2) < 1
         g = [zeros(size(g,1),1-offset(2)), g];
         offset(2) = 1;
      end
      if offset(2) > size(g,2)
         g = [g, zeros(size(g,1),offset(2)-size(g,2))];
      end
   
      % Compute convolution
      y = zeros(size(f)+size(g)-[1,1]);
      m = size(g,1);
      n = size(g,2);
      for i=1:size(f,1)
         for j=1:size(f,2)
            y(i:i+m-1,j:j+n-1) = y(i:i+m-1,j:j+n-1) + f(i,j) * g;
         end         
      end
   
      % Truncate result if needed
      if truncated
        y = y(offset(1):offset(1)+size(f,1)-1,...
              offset(2):offset(2)+size(f,2)-1);
      end
   end
end
