function result = subsasgn(op,s,b)
%SUBSASGN   Subscribed assignment.

%   Copyright 2009, Ewout van den Berg and Michael P. Friedlander
%   See the file COPYING.txt for full copyright information.
%   Use the command 'spot.gpl' to locate this file.

%   http://www.cs.ubc.ca/labs/scl/spot

switch s.type
   case {'.'}
      % Set properties and flags
      op.(s.subs) = b;
      result = op;

   case {'{}'}
      error('Cell-index access is read-only.');
 
   case {'()'}

      % Get operator size
      [m,n] = size(op);
      
      % Do not allow one-dimensional indexing
      if length(s.subs) == 1
         error('Vectorized subset assignments are not supported.');
      end
      
      % Ensure numeric vectors are full and in vectorized form
      for i=1:length(s.subs)
        idx = s.subs{i}; idx = idx(:);
        if issparse(idx), idx = full(idx); end;
        s.subs{i} = idx;
      end

      % Check dimensions (required when more than two dimensions are
      % given)
      dims = ones(1,length(s.subs));
      dims(1) = Inf; % No bound (can grow)
      dims(2) = Inf; % No bound (can grow)
      for i=1:length(s.subs)
         idx = s.subs{i};
         
         if isempty(idx)
            % Fine
         elseif strcmp(idx,':')
            % Fine
         elseif islogical(idx)
            if (length(idx) > dims(i))
               error('Index exceeds operator dimensions.');
            end
         elseif spot.utils.isposintmat(idx)
            if (max(idx) > dims(i))
                error('Index exceeds operator dimensions.');
            end
         else
            error(['Subscript indices must either be real positive ' ...
                   'integers or logicals.']);
         end
      end

      % Reset first and second dimensions
      dims(1) = m; dims(2) = n;

      % Check if all indices in given dimension have been specified
      allIndex   = zeros(2,1);
      emptyIndex = zeros(2,1);
      sizeIndex  = zeros(2,1);
      for i=1:2
         idx = s.subs{i};

         if strcmp(idx,':')
            allIndex(i) = 1;
            sizeIndex(i)= dims(i);
         elseif islogical(idx)
            if (length(idx) == dims(i) && all(idx))
               allIndex(i) = 1;
            elseif all(idx == false)
               emptyIndex(i) = 1;
            end
            sizeIndex(i) = length(idx);
         elseif isnumeric(idx)
            if (max([idx;0]) == dims(i) && length(unique(idx)) == dims(i))
               allIndex(i) = 1;
            elseif isempty(idx)
               emptyIndex(i) = 1;
            end
            sizeIndex(i) = length(idx);
         end
      end
    
      
      % ---------------------------------------------------------------
      % Handle special case where B = []; this will delete rows or
      % columns from the operator
      % ---------------------------------------------------------------
      if ((size(b,1) == 0) && (size(b,2) == 0))
         % Both dimensions fully specified
         if allIndex(1) && allIndex(2)
            % Empty operator
            result = opEmpty(0,0);
         elseif allIndex(1)
            % Excise columns
            result = opExcise(op,s.subs{2},'Cols');
         elseif allIndex(2)
            % Excise rows
            result = opExcise(op,s.subs{1},'Rows');
         elseif emptyIndex(1) && emptyIndex(2)
            % Assign empty matrix to emtpy subset
            result= op;
         else
            error('Subscripted assignment dimension mismatch.');
         end
         
         return;
      end % B = []

      % ---------------------------------------------------------------
      % Check if size of indices and b match
      % ---------------------------------------------------------------
      if ~isscalar(b) && (size(b,1) ~= sizeIndex(1) || size(b,2) ~= sizeIndex(2))
         error('Subscripted assignment dimension mismatch.');
      end

      % ---------------------------------------------------------------
      % Handle the general case
      % ---------------------------------------------------------------
      if isempty(b)
         result = op;
      else
         result = opSubsAsgn(op,s.subs{1},s.subs{2},b);
      end
end
