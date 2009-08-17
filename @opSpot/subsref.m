function varargout = subsref(op,s)
%SUBSREF   Subscripted reference.
   
%   Copyright 2009, Ewout van den Berg and Michael P. Friedlander
%   See the file COPYING.txt for full copyright information.
%   Use the command 'spot.gpl' to locate this file.

%   http://www.cs.ubc.ca/labs/scl/spot

if length(s) > 1
   result = op;
   for i=1:length(s)
      if iscell(result)
         if strcmp(s(i).type,'{}')
            result = builtin('subsref',result,s(i));
         else
            % Apply the subsref to each element
            newresult = cell(1,length(result));
            for j=1:length(result)
               newresult{j} = subsref(result{j},s(i));
            end
            result = newresult;
         end
      else
         result = subsref(result,s(i));
      end
   end
   
   if nargout > 1
      for i=2:nargout
         varargout{i} = [];
      end
   end
   varargout{1} = result;
   
   return;
end


switch s.type
   case {'.'}
      % Set properties and flags
      varargout{1} = op.(s.subs);

   case {'{}'}
      error('Cell-indexing is not yet supported.');
 
   case {'()'}
      % Get operator size
      [m,n] = size(op);

      % Ensure numeric vectors are full
      for i=1:length(s.subs)
        if issparse(s.subs{i}), s.subs{i} = full(s.subs{i}); end;
      end


      % Process query
      if (length(s.subs) == 1)
         % --------------------------------------------------
         % One-dimensional indexing; return explicit matrix
         % --------------------------------------------------
         idx   = s.subs{1};
         [p,q] = size(idx);
         idx   = idx(:);
         
         if isempty(idx)
            result = [];
           
         elseif strcmp(idx,':')
            % Get all entries
            result = double(op);
            result = result(:);
           
         elseif islogical(idx)
            % Check index range
            if (numel(idx) > m*n) ...
               || ((min(size(idx)) > 1) && (size(idx,1) > m || ...
                                            size(idx,2) > n))
               error('Index out of bounds.');
            end
            
            % Add padding to index and reshape
            idx = idx(:);
            if mod(length(idx),m) ~= 0
               idx = [idx; false(m-mod(length(idx),m),1)];
            end            
            idx = reshape(idx,m,round(length(idx)/m));

            % Create matrix version of operator, restricted to the
            % rows or columns accessed (this reduces the number of
            % operator applications needed to generate the explicit
            % matrix)
            colIdx = find(any(idx,1));
            rowIdx = find(any(idx,2));
            
            if length(rowIdx) < length(colIdx)
               idx = idx(rowIdx,:);
               
               % Prepare ssub structure (cannot use (:,colIdx))
               ssub = struct();
               ssub.subs = {rowIdx,':'};
               ssub.type = '()';
               
               matrix  = double(subsref(op,ssub)')';
               matrix  = matrix(:);
               result  = matrix(idx);
            else
               idx = idx(:,colIdx);
               
               % Prepare ssub structure (cannot use (:,colIdx))
               ssub = struct();
               ssub.subs = {':',colIdx};
               ssub.type = '()';
            
               matrix  = double(subsref(op,ssub));
               matrix  = matrix(:);
               result  = matrix(idx);
            end
                        
            if p == 1, result = result'; end
            
         elseif spot.utils.isposintmat(idx)
            % Check index range
            if any(idx > m*n)
               error('Index out of bounds.');
            end
            
            % Create matrix version of operator, restricted to the
            % rows or columns accessed (this reduces the number of
            % operator applications needed to generate the explicit
            % matrix)
            colIdx  = floor((idx+m-0.5)/m);
            rowIdx  = mod(idx-1,m) + 1;
            columns = unique(colIdx);
            rows    = unique(rowIdx);
            
            if length(rows) < length(columns)
               rowMap =  zeros(max(rows),1);
               rowMap(rows) = 0:length(rows)-1;
               
               % Prepare ssub structure (cannot use (rows,:) in call)
               ssub = struct();
               ssub.subs = {rows,':'};
               ssub.type = '()';
               
               matrix  = double(subsref(op,ssub)');
               matrix  = matrix(:);
               result  = reshape(matrix(colIdx + rowMap(rowIdx)*n), p,q);
            else
               colMap = zeros(max(columns),1);
               colMap(columns) = 0:length(columns)-1;

               % Prepare ssub structure (cannot use (:,columns))
               ssub = struct();
               ssub.subs = {':',columns};
               ssub.type = '()';
            
               matrix  = double(subsref(op,ssub));
               matrix  = matrix(:);
               result  = reshape(matrix(rowIdx + colMap(colIdx)*m), p,q);
            end
            
         else
            error('Invalid data type used for indexing.');
         end
         
         varargout{1} = result; % Numerical result
         
      else
         % --------------------------------------------------
         % Higher-dimensional indexing -- create sub-operator
         % --------------------------------------------------

         % Check dimensions
         dims = ones(length(s.subs),1);
         dims(1) = m;
         dims(2) = n;
         for i=1:length(s.subs)
             idx = s.subs{i}; idx = idx(:); s.subs{i} = idx;
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

         varargout{1} = opSubsRef(op,s.subs{1},s.subs{2});
      end
end
