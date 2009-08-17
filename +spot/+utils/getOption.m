function v = getOption(opts, field, default)
%getOption  Get structure field with default
%
%   getOption(OPTS, FIELD, DEFAULT) returns the value of OPTS.FIELD,
%   if OPTS does not have the given FIELD, the DEFAULT value is
%   returned.

%   Copyright 2008, Ewout van den Berg and Michael P. Friedlander
%   See the file COPYING.txt for full copyright information.
%   Use the command 'spot.gpl' to locate this file.

%   http://www.cs.ubc.ca/labs/scl/spot

   import spot.utils.*

   field = fieldname(field);
   if isfield(opts,field)
      v = opts.(field);
   else
      v = default;
   end
end
