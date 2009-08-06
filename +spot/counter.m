classdef counter < handle
   properties
      mode1=0 % count of A *x
      mode2=0 % count of A'*y
   end % properties
   methods
      
      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
      function c = counter()
      %counter  Constructor
      end

      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
      function varargout = subsref(obj,s)
      %subsref  Subscribed reference
         switch s.type
            case {'.'}
               % Set properties and flags
               varargout{1} = obj.(s.subs);
            case {'{}'}
               error('Cell-indexing is not supported.');
            case {'()'}
               idx = s.subs{1};
               if isempty(idx)
                  varargout{1} = [];
               elseif strcmp(idx,':')
                  varargout{1} = [obj.mode1, obj.mode2];
               elseif idx == 1
                  varargout{1} = obj.mode1;
               elseif idx == 2
                  varargout{1} = obj.mode2;
               else
                  error('Argument must be 1, 2, or ":"');
               end
         end % switch s.type
      end % function subsref
      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
      function obj = subsasgn(obj,s,val)
      %subsasgn  Subscribed reference
         switch s.type
            case {'{}'}
               error('Cell-indexing is not supported.');
            case {'.'}
               obj.(s.subs) = val;
            case {'()'}
               idx = s.subs{1};
               if isempty(idx)
                  % relax
               elseif strcmp(idx,':')
                  if length(val) ~= 2
                     error('Assignment must have length 2')
                  end
                  obj.mode1 = val(1);
                  obj.mode2 = val(2);
               elseif idx == 1
                  if length(val) ~= 1
                     error('Assignment must have length 1')
                  end
                  obj.mode1 = val;
               elseif idx == 2
                  if length(val) ~= 1
                     error('Assignment must have length 1')
                  end
                  obj.mode2 = val;
               else
                  error('Argument must be 1, 2, or ":"');
               end
         end % switch s.type
      end % function subsref
      function uplus(obj)
         display('Yes!')
      end
   end % methods
end % classdef