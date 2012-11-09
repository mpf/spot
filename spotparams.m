function p = spotparams(varargin)
%SPOTPARAMS  Get or set default Spot parameters.
%
%   SPOTPARAMS('key',VAL) sets one or more global Spot parameters.
%
%   SPOTPARAMS, with no arguments, displays the current parameters values.
%
%   The parameters, their default values, and a brief description:
%
%   'cgtol'      1e-6   convergence tolerance for the CG-type solver
%   'cgitsfact'  1      max number of CG itns = cgitsfactor * min{m,n,20}
%   'cgshow'     false  show output from CG itns
%   'cgdamp'     0      LSQR damping parameter
%   'conlim'     1e8    Condition number limit on LSQR solves

%   Copyright 2009, Ewout van den Berg and Michael P. Friedlander
%   See the file COPYING.txt for full copyright information.
%   Use the command 'spot.gpl' to locate this file.

%   http://www.cs.ubc.ca/labs/scl/spot
   
   import spot.utils.*

   % Default options
   defopts.cgtol     = 1e-6;   % convergence tolerance for CG-type solver
   defopts.cgitsfact = 1;      % max CG itns = cgitsfactor * min{m,n,20}
   defopts.cgshow    = false;  % show output from CG itns
   defopts.cgdamp    = 0;      % LSQR damping parameter
   defopts.conlim    = 1e8;    % Condition number limit on LSQR solves
   
   % This structure saves the default or user-modifed parameters.
   persistent savedopts

   % If this is the very first call to spotparms, save default options.
   if isempty(savedopts)
      savedopts = defopts;
   end

   % User is asking for the value of a param. Return it and exit.
   if nargin == 1 && ischar(varargin{1}) && isfield(savedopts,varargin{1})
      p = savedopts.(varargin{1});
      return
   elseif nargin == 0
      p = savedopts;
      return
   end
   
   % Parse user-supplied options.
   validOpts = fieldnames(defopts);
   parm = parseOptions(varargin,{'default','defaults'},validOpts);

   if parm.default || parm.defaults
      % Set and return default options if 'default' flag given.
      savedopts = defopts;
      p = defopts;
      return
   end  
   
   % The user may have changed saved option values. Save these.
   for i=1:length(validOpts)
      opti = validOpts{i};
      if isfield(parm,opti) && parm.(opti) ~= savedopts.(opti)
         savedopts.(opti) = parm.(opti);
      end
   end
   
   p = savedopts;
end