%% Spot: A Linear-Operator Toolbox
% Ewout van den Berg and <http://www.cs.ubc.ca/~mpf Michael P Friedlander>

%%
% Linear operators are at the core of many of the most basic algorithms
% for signal and image processing. Matlab's high-level, matrix-based
% language allows us to naturally express many of the underlying matrix
% operations (e.g., computation of matrix-vector products and
% manipulation of matrices) and is thus a powerful platform on which to
% develop concrete implementations of these algorithms. Many of the most
% useful operators, however, do not lend themselves to the explicit
% matrix representations that Matlab provides. The aim of the Spot
% Toolbox is to bring the expressiveness of Matlab's built-in matrix
% notation to problems for which explicit matrices are not practical.

%%
% Please visit the <http://www.cs.ubc.ca/labs/spot Spot website> to
% download the latest version of the toolbox.

%% Installation
% The Spot toolbox requires Matlab version *R2008a or later*.  In
% particular, Spot makes extensive use of the "new" object-oriented
% features (defined by the "classdef" keyword) that were introduced in
% the first quarter of 2008 later. It's been extensively tested against
% R2009a and R2009b. Please make sure to email one of the authors if you
% notice some incompatibility.

%%
% Spot is prepackaged with all of its required dependencies, and
% the core functionality will work out-of-the-box.  The first step
% is to add the "spotbox" directory to your Matlab path:
%
%  addpath /path/to/spotbox/directory
%
% See the <http://www.mathworks.com/access/helpdesk/help/techdoc/matlab_env/f10-26235.html
% MATLAB documentation for setting the search path>.
        
%% Getting Started
%       
% * <docguide_quick.html A Quick Guide to Spot>

%%        
% _Copyright 2008-2009 Ewout van den Berg and Michael P. Friedlander_
