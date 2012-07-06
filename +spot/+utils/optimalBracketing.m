function result = optimalBracketing(op,tree)
   
   if nargin < 2 || isempty(tree)
      tree = spot.utils.spottree(op);
   end
   
   chain = buildChain(tree);
   [chain, s] = filterChain(chain);
   
   if s~=1
      result = opMatrix(s)*optimizeChain(chain);
   else
      result = optimizeChain(chain);
   end
   
end % function optimalBracketing

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [result] = optimizeChain(chain)
   
   [s, m] = findBracketOrder(chain);
   result = constructNewOp(chain, s);
   
end % function optimizeChain

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [s, m] = findBracketOrder(chain)
   % Introduction to Algorithms, 1990, Cormen, p306
   n = numel(chain);
   m = zeros(n);
   s = zeros(n);
   
   for i=1:n
      m(i,i) = 0;
   end
   
   for l = 2:n
      for i=1:n-l+1
         j=i+l-1;
         m(i,j) = inf;
         pi=chain{i}.size;
         pj=chain{j}.size;
         const = pi(1)*pj(2);
         for k =i:j-1
            pk=chain{k}.size;
            q = m(i,k)+m(k+1, j)+const*pk(2);
            if q < m(i,j)
               m(i,j)=q;
               s(i,j)=k;
            end
         end
      end
   end
   
end % function findBracketOrder

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function result = constructNewOp(chain, s, i, j)
   % Introduction to Algorithms, 1990, Cormen, p308
   if nargin < 3
      i = 1;
      j = numel(chain);
   end
   
   if j > i
      X = constructNewOp(chain, s, i, s(i,j));
      Y = constructNewOp(chain, s, s(i,j)+1, j);
      result = X*Y;
   else
      result = chain{i};
   end
   
   % n = numel(chain);
   % k = s(1,n);
   % s1 = s(1:k,1:k);
   % s2 = s(k+1:end, k+1:end);
   % result = constructNewOp(chain(1:k),s1)*constructNewOp(chain(k+1:end),s2);
   
end % function constructNewOp

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function result = buildChain(tree, transposed)
   
   if nargin < 2
      transposed = false;
   end
   
   result = {};
   
   %Transposed matrices have to be handled differently
   if isa(tree.node.op, 'opCTranspose')
      result = buildChain(tree.children(1), true);
      return
   end
   
   if transposed
      %if the current node is an opFoG all of its children belongs to the current
      %chain
      if isa(tree.node.op, 'opFoG')
         n = numel(tree.children);
         for i = n:-1:1
            result = [result; buildChain(tree.children(i), transposed)];
         end
         %else return a one element chain, for which the element should be
         %optimized.
      else
         %if the operator is a leave then the chain is just the leave itself
         result = {tree.node.op'};
         %if the operator contains children, then all children should be
         %optimized
         if tree.node.height~=1
            curOp = tree.node.op;
            n = numel(curOp.children);
            children = cell(1,n);
            for i = 1:n
               %                 curOp.children{i} = optimalBracketing(curOp.children{i}, tree.children{i});
               children{i} = spot.utils.optimalBracketing(curOp.children{i}, tree.children(i));
            end
            curOp.children = children;
            result = {curOp'};
         end
      end
   else
      %if the current node is an opFoG all of its children belongs to the current
      %chain
      if isa(tree.node.op, 'opFoG')
         n = numel(tree.children);
         for i = 1:n
            result = [result; buildChain(tree.children(i))];
         end
         %else return a one element chain, for which the element should be
         %optimized.
      else
         %if the operator is a leave then the chain is just the leave itself
         result = {tree.node.op};
         %if the operator contains children, then all children should be
         %optimized
         if tree.node.height~=1
            curOp = tree.node.op;
            n = numel(curOp.children);
            children = cell(1,n);
            for i = 1:n
               %                 curOp.children{i} = optimalBracketing(curOp.children{i}, tree.children{i});
               children{i} = spot.utils.optimalBracketing(curOp.children{i}, tree.children(i));
            end
            curOp.children = children;
            result = {curOp};
         end
      end
   end
end % function buildChain

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [result, s] = filterChain(chain)
   
   result = [];
   n = numel(chain);
   
   s = 1;
   for i = 1:n
      if size(chain{i})==[1 1]
         s=chain{i}*s;
      else
         result = [result; {chain{i}}];
      end
   end
   
end % function filterChain
