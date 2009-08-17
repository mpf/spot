function [opts,args] = parseOptions(args, flagFields, optsFields)
%parseOptions  Parse options
%
%   [OPTS,ARGS] = parseOptions(ARGS,FLAGFIELDS,OPTSFIELDS) goes
%   throught parameter list ARGS and looks for all flag strings
%   indicated by FLAGFIELDS and keyword-value pairs with keywords
%   given by OPTSFIELDS. All flag fields and encountered
%   keyword-value pairs are stored in OPTS. The remaining arguments
%   are returned in ARGS.

%   Copyright 2008-2009, Ewout van den Berg and Michael P. Friedlander
%   See the file COPYING.txt for full copyright information.
%   Use the command 'spot.gpl' to locate this file.

%   http://www.cs.ubc.ca/labs/scl/spot
   
   import spot.utils.*
   
   % Initialize flag structure
   opts = struct();
   for i=1:length(flagFields)
      flagFields{i} = lower(flagFields{i});
      opts = setfield(opts,fieldname(flagFields{i}),0);
   end
   
   for i=1:length(optsFields)
      optsFields{i} = lower(optsFields{i});
   end
   
   % Parse and remove flags
   idx = [];
   for i=1:length(args)
      idxflag = 1;
      
      if ischar(args{i})
         field = lower(args{i});
         
         for j=1:length(flagFields)
            if strcmp(field,flagFields{j})
               opts = setfield(opts,fieldname(flagFields{j}),1);
               idxflag = 0;
               break;
            end
         end
      end
      
      if idxflag, idx(end+1) = i; end;
   end
   if ~isempty(args), args = args(idx); end;
   
   % Parse parameter pairs
   idx = []; i = 1;
   while i <= length(args)
      idxflag = 1;
      if ischar(args{i}) && (i+1 <= length(args))
         field = lower(args{i});
         
         for j=1:length(optsFields)
            if strcmp(field,optsFields{j})
               opts = setfield(opts,fieldname(optsFields{j}),args{i+1});
               idxflag = 0;
               break;
            end
         end
         
         if idxflag, idx = [idx i i+1]; end;
         i = i + 2;
      else
         idx = [idx i];
         i   = i + 1;
      end
   end
   if ~isempty(args), args = args(idx); end;
end
