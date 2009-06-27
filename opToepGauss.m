%opToepGauss  Toeplitz matrix with Gaussian entries
%
%   OP = opToepGauss(M,N,TYPE,NORMALIZED) creates an M by N Toeplitz
%   matrix with Gaussian entries. TYPE can either be 'toeplitz' or
%   'circular'. For the 'toeplitz' type matrix, m+n-1 different
%   generating entries are generated at random, whereas for the
%   'circular' matrix, only max(m,n) are needed. When the TYPE field
%   is empty [], or not specified 'toeplitz' is chosen by
%   default. Setting the NORMALIZED flag scales the columns of the
%   Toeplitz matrix to unit norm. Multiplication is implemented using
%   the fast Fourier transform. The use of such matrices in compressed
%   sensing was suggested by:
%
%   [1] W. U. Bajwa, J. D. Haupt, G. M. Raz, S. J. Wright, and
%       R. D. Nowak, Toeplitz-Structured Compressed Sensing Matrices,
%       IEEE/SP 14th Workshop on Statistical Signal Processing,
%       pp. 294-298, August 2007.
%
%   See also opToeplitz, opToepSign.

%   Copyright 2009, Ewout van den Berg and Michael P. Friedlander
%   http://www.cs.ubc.ca/labs/scl/sparco
%   $Id: opToepGauss.m 39 2009-06-12 20:59:05Z ewout78 $

classdef opToepGauss < opToeplitz

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Methods - Public
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    methods
        
        % Constructor
        function op = opToepGauss(m,n,type,normalized)

           if nargin < 3 || isempty(type)
              type = 'Toeplitz';
           end
           if nargin < 4
              normalized = 0;
           end
           
           switch lower(type)
              case 'circular'
                 % Generate the entries of the matrix
                 k  = max(m,n);
                 v  = randn(k,1);
       
              case 'toeplitz'
                 % Generate the entries of the matrix
                 v  = randn(m+n-1,1);

              otherwise
                 error('Unrecognized type parameter.');
           end

           % Construct operator
           op = op@opToeplitz(m,n,v,type,normalized);
           op.type = 'ToepGauss';
        end % Constructor
        
    end % Methods
        
end % Classdef
