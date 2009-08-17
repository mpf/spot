function str = fieldname(name)
%FIELDNAME Convert parameter name to valid structure field name.
%
%   STR = fieldname(NAME) converts parameter NAME to a lower-case
%   field name, replacing all non-alphanumeric charachters by
%   underscores.
%
%   See also parseParams, getOption

%   Copyright 2008, Ewout van den Berg and Michael P. Friedlander
%   See the file COPYING.txt for full copyright information.
%   Use the command 'spot.gpl' to locate this file.

%   http://www.cs.ubc.ca/labs/scl/spot

str = regexprep(lower(name),'\W','_');

