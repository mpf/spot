classdef spottree
%spottree
%
%   Copyright 2009, Kai Chen and Michael P. Friedlander
%   See the file COPYING.txt for full copyright information.
%   Use the command 'spot.gpl' to locate this file.

%   http://www.cs.ubc.ca/labs/scl/spot

   properties
      node = struct();
      children = [];
   end

   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   % Methods - public
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   methods
      
      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
      function tree = spottree(op)
      %spottree  Construct a spot tree.

         tree.node.op = op;
         s = numel(op.children);
      
         if s~=0
            maxChildHeight = 0;
            totalChildLeaves = 0;
            for i = 1:s
               child = spot.utils.spottree(op.children{i});
               tree.children = [tree.children, child];
               totalChildLeaves = totalChildLeaves + child.node.leaves;
               maxChildHeight = max(maxChildHeight, child.node.height);
            end
            tree.node.height = maxChildHeight+1;
            tree.node.leaves = totalChildLeaves;
         else
            tree.node.height = 1;
            tree.node.leaves = 1;
         end
         
      end % function spottree
      
      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

      function plot(tree)
      %plot  Plot the tree using GraphViz.

         tmpFile = 'graphVizInput.txt';
         fid = fopen(tmpFile, 'w+');
         [result,node] = buildGraphVizInput(tree);
         graphVizInput = ['digraph G{\n', result, '}'];
         fprintf(fid, graphVizInput);
         fclose(fid);
         
         figure;
         spot.utils.drawDot(tmpFile, gca);
         set(gca,'DataAspectRatio',[1 1 1]);

         delete(tmpFile)

      end % function plot

      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
      
      function [flops, mul, add] = flops(tree)
      %flops  Compute number of flops needed to aggregate operator.
      %
      % Let 1 flop be 1 scaler multiplication or addition The current
      % function can only handle opSum, opMinus, and opFoG. All other
      % operators are considered to be zero cost, i.e., 0 flops.

         mul = 0;
         add = 0;
         
         if tree.node.height ~= 1
            n = numel(tree.children);
            % Calculate adds and mults required for the children
            for i = 1:n
               [childFlops, childMul, childAdd] = tree.children(i).flops();
               add = add + childAdd;
               mul = mul + childMul;
            end
         
            % Calculate adds and mults required for the current operator
            switch tree.node.op.type
              case 'FoG'
                sLeft = size(tree.children(1).node.op);
                sRight = size(tree.children(2).node.op);
                add = add + sLeft(1)*(sLeft(2)-1)*sRight(2);
                mul = mul + sLeft(1)*sLeft(2)*sRight(2);
              case {'Sum', 'Minus'}
                s = size(tree.children(1).node.op);
                add = add + s(1)*s(2);
            end
         end
      
         flops = mul+add;
      
      end % function flops

      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
      
   end % methods - public
   
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   % Methods - private
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

   methods (Access = private)      

      function [result,node] = buildGraphVizInput(tree,node)
      %buildGraphVizInput  Helper routine for plot method.
         if nargin < 2 || isempty(node)
            node = 0;
         end
         
         numChildren = numel(tree.children);
         
         curNode = ['node_', num2str(node)];
         if isscalar(tree.node.op)
            opType = 'Scaler';
         else
            opType = tree.node.op.type;
         end
         [m,n]   = size(tree.node.op);
         opLabel = sprintf('%s %dx%d',opType,m,n);
    
         result = [curNode, ' [label="', opLabel,'"];\n'];

         if numChildren == 0
            result = [result, curNode, ' [shape=box];\n'];
         else
            for i = 1:numChildren
               node = node+1;
               childS = size(tree.children(i).node.op);
               childNode = ['node_', num2str(node)];
               result = [result , curNode, '->', childNode, ';\n'];
               [res,node] = buildGraphVizInput(tree.children(i),node);
               result = [result, res];
            end
         end

      end % function buildGraphVizInput

      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
      
   end % methods - private
      
end % classdef
