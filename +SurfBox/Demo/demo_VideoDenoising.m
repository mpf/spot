%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%	SurfBox-MATLAB (c)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%--------------------------------------------------------------------------
%	SurfBox-MATLAB (c)
%--------------------------------------------------------------------------
%
%	Yue M. Lu and Minh N. Do
%
%--------------------------------------------------------------------------
%
%	demo_VideoDenoising.m
%	
%	First created: 12-12-08
%	Last modified: 12-12-08
%
%--------------------------------------------------------------------------

% In this demo, we apply the 3-D surfacelet transform to remove additive
% white Gaussian noise added to a video sequence. This is achieved by
% simply applying hard-thresholding on the surfacelet coefficients.
% Substantial improvement can be expected if a more advanced denoising
% method is used.
%
% We use the four video sequences reported in our paper.
% 
% Y. M. Lu and M. N. Do, Multidimensional Directional Filter Banks and
% Surfacelets, IEEE Transactions on Image Processing, vol. 16, no. 4, April 2007.
%
% All four sequences are of size 192 * 192 * 192, saved in the mat format. 
%



disp('Video denoising using the surfacelet transform')
disp(' ')
disp('Note: This demo is memory intensive. At least 2 GB of RAM is needed.');
disp('To free up more memory space, you might want to close all other running programs before starting this demo.');

%% We first load a video sequence
disp(' ');
disp('Load a video sequence:');
disp(' 1. mobile');
disp(' 2. coastguard');
r = input('Choose a video sequence (1 or 2): ');
if isempty(r)
    r = 1;
end
switch r
    case 1
        load mobile2_sequence % An array X of size 192 * 192 * 192 have been loaded
    case 2
        load coastguard_sequence 
    otherwise
        error('Please choose a video by entering a number between 1 to 2');
end

r = input('Press <enter> to play the original sequence ...');
PlayImageSequence(X);

%% We add Gaussian noise to the video sequence
disp(' ');
disp('Step 2: Add white Gaussian noise to the sequence.');
sigma = 20; % standard deviation
Xn = double(X) + sigma * randn(size(X));
r = input('Press <enter> to play the noisy sequence ...');
PlayImageSequence(uint8(Xn));

%% Surfacelet Denoising
disp(' ');
disp('Step 3: Apply surfacelet transform on the noisy sequence and hard-threshold the coefficients');
r = input('Press <enter> to continue ...');

disp(' ');
disp('Processing ...');

Pyr_mode = 1.5; % For better performance, choose Pyr_mode = 1. However, this setting requires more RAMs.
Xd = surfacelet_denoising_3D(Xn, Pyr_mode, sigma);
Xd(Xd > 255) = 255;
Xd(Xd < 0) = 0;


disp('Done!');
disp(' ');
r = input('Press <enter> to show the denoised sequence ...');
skip = 10; % To exclude the boundary effect
PlayImageSequence(uint8(Xd(:,:, skip+1 : end - skip)));

% Plot the frame-by-frame PSNR values
PSNR_surf = zeros(size(Xd, 3) - 2 * skip, 1);
for n = skip+1 : size(Xd, 3) - skip
   PSNR_surf(n - skip) = PSNR(double(X(:,:, n)), Xd(:,:,n)); 
end

figure
plot([(skip+1) : (size(Xd, 3) - skip)], PSNR_surf);
axis tight;
title(['Average PSNR = ' num2str(mean(PSNR_surf))], 'FontSize', 12);
xlabel('Frame Number', 'FontSize', 12);
ylabel('PSNR (dB)', 'FontSize', 12);

