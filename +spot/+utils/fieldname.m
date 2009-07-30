function str = fieldname(name)
%FIELDNAME Convert parameter name to valid structure field name.
%
%   STR = fieldname(NAME) converts parameter NAME to a lower-case
%   field name, replacing all non-alphanumeric charachters by
%   underscores.
%
%   See also parseParams, getOption

%   Copyright 2008, Ewout van den Berg and Michael P. Friedlander
%   http://www.cs.ubc.ca/labs/scl/sparco
%   $Id: fieldname.m 1402 2009-06-18 23:35:43Z mpf $

str = regexprep(lower(name),'\W','_');
end
