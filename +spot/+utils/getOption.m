function v = getOption(opts, field, default)
%getOption  Get structure field with default
%
%   getOption(OPTS, FIELD, DEFAULT) returns the value of OPTS.FIELD,
%   if OPTS does not have the given FIELD, the DEFAULT value is
%   returned.

%   Copyright 2008, Ewout van den Berg and Michael P. Friedlander
%   http://www.cs.ubc.ca/labs/scl/sparco
%   $Id: getOption.m 1402 2009-06-18 23:35:43Z mpf $

   import spot.utils.*

   field = fieldname(field);
   if isfield(opts,field)
      v = opts.(field);
   else
      v = default;
   end
end
