function tree = buildTree(op)
%buildTree  Build the computational graph of a Spot operator.
%
%   Copyright 2009, Kai Chen, Ewout van den Berg, and Michael P. Friedlander
%   See the file COPYING.txt for full copyright information.
%   Use the command 'spot.gpl' to locate this file.

%   http://www.cs.ubc.ca/labs/scl/spot

   tree = struct();
   tree.node = struct();
   tree.node.op = op;
   tree.children = {};

   s = numel(op.children);

   if s~=0
      maxChildHeight = 0;
      totalChildLeaves = 0;
      for i = 1:s
         child = buildTree(op.children{i});
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

end % function buildTree
