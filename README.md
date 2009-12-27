Spot: A linear-operator toolbox for Matlab
==========================================

Spot is a Matlab toolbox for the construction, manipulation, and
application of linear operators. The aim of the Spot Toolbox is to
bring the expressiveness of Matlab's built-in matrix notation to
problems for which explicit matrices are not practical. Spot includes
a collection of fundamental operators (e.g., Fourier, DCT, and
Wavelet), and more complex operators can be easily constructed using
overloaded versions of Matlab's more familiar matrix-manipulation
functions.

Downloading
-----------

Please visit the [Spot website](http://www.cs.ubc.ca/labs/scl/spot)
for documentation and to download the latest version of the toolbox.

Installation
------------

The Spot toolbox requires Matlab version *R2008a or later*.  In
particular, Spot makes extensive use of the "new" object-oriented
features (defined by the "classdef" keyword) that were introduced in
the first quarter of 2008 later. It's been extensively tested against
R2009a and R2009b. Please make sure to email one of the authors if you
notice some incompatibility.

Spot is prepackaged with all of its required dependencies, and
the core functionality will work out-of-the-box.  The first step
is to add the "spotbox" directory to your Matlab path:

 addpath /path/to/spotbox/directory

See
the [MATLAB documentation for setting the search path](http://www.mathworks.com/access/helpdesk/help/techdoc/matlab_env/f10-26235.html).
