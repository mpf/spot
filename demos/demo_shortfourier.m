%% Windowed Fourier
% This demo illustrates the use of opBlockDiag in conjunction with
% opFFT and opWindow to obtain a spectrograph of an audio signal.

% Load the data
% Chief Wiggum: "Hey hi, can I arrest any of you people for anything?"
[data,samplingRate] = wavread('./data/WiggumArrest.wav');

% Create the Fourier and window operators
blockSize = 256;
F = opDFT(blockSize);
W = opWindow(blockSize,'Hamming');

%  Set overlap of each block and compute number of blocks
blockOverlap = 128;
nBlocks = 1 + ceil((length(data) - blockSize) / blockOverlap);

% Create short-time windowed Fourier transform
O = F*W; O(blockSize/2+2:end,:) = [];
T = opBlockDiag(nBlocks,O,-blockOverlap);
T = T(:,1:length(data));

% Get spectrum
freq = T * data;
pcolor(log(abs(reshape(freq,1+blockSize/2,nBlocks)))),shading flat;



