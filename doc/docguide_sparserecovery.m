%% Sparse Recovery
% One of Spot's major applications is compressed sensing. In compressed
% sensing, a sparse signal (one with only a few nonzero values) is
% sampled below the <http://en.wikipedia.org/wiki/Nyquist_rate Nyquist rate>,
% but with a particular sampling method that allows it to be reconstructed
% later. This enables measurements that are faster and consume
% less memory. For example, a 2007 paper by <http://www.stanford.edu/~mlustig/ Lustig et al.>
% showed that MRI images can be acquired five times as fast using
% compressed sensing techniques.
%
% Some signals are inherently sparse (sparse in the Dirac basis), such as images that only have a few
% nonzero pixel values. However, compressed sensing has a wide range of
% applications because many signals can be made sparse through particular
% transforms; for example, the Fourier transform of a sine wave is very
% sparse because the wave only contains one frequency. In this
% example, we will simply create a generic sparse signal.
%
% If we sample the signal (represented by the vector |x0|) using a matrix
% |A|, we get the smaller vector |b|:
%
% $$A*x_0=b$$
%
% |b| must be smaller than |x|, otherwise no compression of the signal has occured.
% This means that the matrix |A| must have fewer rows than columns, and the system is
% "underdetermined", having more unknowns than equations. This usually
% means that the vector |b| is not unique, and if we try to solve the system for |x0| using |A| and |b|, we
% will get many different solutions. However, in compressed sensing, we can guarantee that
% that we will be able to solve the system to recover the original signal.
% This guarantee requires two things: first, the signal must be sparse, and
% second, we must use a special kind of measurement matrix. Most of these
% special matrices satisfy the <http://en.wikipedia.org/wiki/Restricted_isometry_property
% "Restricted Isometry Property">.
%
% In this example, we will demonstrate how to create the measurement matrix
% |A| as a Spot operator, use it to take measurements of a sparse signal,
% then reconstruct the signal using a basis pursuit solver called SPGL1.

%% Creating an Example Signal
% Let's create a sparse signal that we can measure and reconstruct. We will
% create a "spike train" signal, which only has -1 and 1 magnitudes.
% Our signal will have |k| nonzero values out of |n| values.
n = 512; k = 20;

%%
% Create a random permutation of the integers 1 to |n|; the
% first |k| of these will be the indices of the signal's nonzero values.
p = randperm(n);

%%
% Initialize the signal |x0| as a column vector of |n| zeros. Set the
% designated nonzero values to be randomly 1 or -1:
x0 = zeros(n,1);
x0(p(1:k)) = sign(randn(k,1));

%%
% Plot the resulting signal:
figure(1); plot(1:n, x0);
axis([0 512 -1.5 1.5]);

%% Taking Measurements
% Now that we have a signal, we have to create the measurement matrix to
% sample it. Gaussian matrices, which have entries randomly
% chosen from the Gaussian (or normal) distribution, satisfy the
% Restricted Isometry Property. We will use one for our measurement
% matrix. It must have |n| columns (the number of rows in the signal vector
% |x0|), but the number of rows is our choice. Each row in the measurement
% matrix represents a single measurement, as it will produce a single entry
% in the resulting vector. As a rule of thumb, the number of measurements should
% be about five times as large as the number of nonzero values; we'll use six times:
m = 120;

%%
% Instead of an explicit matrix, we can use a Spot
% <http://www.cs.ubc.ca/labs/scl/spot/operators.html#opGaussian |opGuassian|> operator.
% Using mode 2 of opGaussian creates an implicit Gaussian matrix. This
% means that the columns of the matrix are generated as the operator is
% applied, so that we never have to store the entire matrix.
A = opGaussian(m,n,2)

%%
% To take our measurements, we simply have to apply |A| to |x0|. Our new
% vector |b| has |m| entries. We will also add some random noise:
b  = A*x0 + 0.005 * randn(m,1);

%%
% This is what our compressed data looks like:
figure(); plot(1:m, b)

%% Reconstructing the Signal
% We have stored our signal as the vector |b|; let's try to recover
% it using |A|. We will use a solver called SPGL1, which solves the following basis
% pursuit denoising problem:
%
% $minimize_{x}\|x\|_1 \;subject\;to\; \|Ax\ ^\_ \ b\|_2 \leq \sigma$
%
% The second half of this problem is our condition that |x| actually
% satisfies the equation $Ax=b$ within some range represented by $\sigma$.
% Minimizing the 1-norm of |x| gives us the sparsest |x| that meets
% this condition.
%
% First we will set our "optimality tolerance" to 0.0001. This means that
% the solution that the solver finds is guaranteed to be within 0.01% of
% the optimal solution.
opts = spgSetParms('optTol', 1e-4, 'verbosity', 1);

%%
% Next we simply pass |A|, |b|, $\sigma =0.001$, and our parameters to the
% SPGL1 solver:
[x,r,g,info] = spg_bpdn(A,b,1e-3,opts);

%%
% You can see that the solver stopped once the relative error became less
% than 0.0001. Let's plot the reconstruction, |x|, with the original signal,
% |x0|:
figure(2); plot(1:n, x0, 1:n, x);
axis([0 550 -1.5 1.5]);
legend('truth', 'recovery');

%%
% The signal and reconstruction overlap almost completely, so our
% reconstruction is accurate.
