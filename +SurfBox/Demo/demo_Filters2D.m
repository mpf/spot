%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%	SurfBox-MATLAB (c)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%%	Yue Lu and Minh N. Do
%%
%%	Department of Electrical and Computer Engineering
%%	Coordinated Science Laboratory
%%	University of Illinois at Urbana-Champaign
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%%	demo_Filters2D.m
%%	
%%	First created: 04-22-06
%%	Last modified: 04-23-06
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

disp(' ');
disp(' ');
disp(['In this demo, we plot the magnitude frequency responses and spatial']);
disp(['domain basis images of several 2-D surfacelets at a certain scale.']);
disp(' ');
disp(['Make sure the Matlab directory of SurfBox is on the search path.']);
disp(' ');


r = input('Press <enter> to continue ...');

%% Note: make sure the Matlab folder of SurfBox is on the search path.

%% Set the parameters here
%% The test image will be an N * N matrix
N = 512;

%% We will have 2^(L+1) different directional subbands at each scale
L = 2;

%% We show surfacelets at the scale at "iScale".
iScale = 3;

%% The order of the checkerboard filter banks. The higher bo is, the
%% sharper the frequency response is.
bo = 12; 

%% Resolution of the frequency plot
K = 64;

%% Build the signal
X = zeros(N);

Lev_array = cell(1, iScale);

for i = 1 : iScale - 1
    Lev_array{i} = [-1 0; 0 -1];
end
Lev_array{iScale} = [-1 L; L -1];

Pyr_mode = 1;


%% Surfacelet Decomposition
[Y, Recinfo] = Surfdec(X, Pyr_mode, Lev_array, 'ritf', 'bo', bo);

h = figure('name', '2-D Surfacelets (Top two rows: frequency domain, Bottom two rows: spatial domain)', 'NumberTitle', 'off');
clf; colordef(h, 'none'); colormap jet; set(gcf,'Position',[50,50,640,640]);

c = 1;
for m = 1 : 2
    for n = 1 : 2 ^ L
        subband = Y{iScale}{m}{n};
        sz = size(subband);
        subband(sz(1)/2, sz(2)/2) = 1;
        Y{iScale}{m}{n} = subband;
        
        %% Surfacelet reconstruction
        Rec = Surfrec(Y, Recinfo);
        
        %% Magnitude frequency responses
        h = subplot(4, 4, c);
        show_freq2D(Rec, K, h);
        drawnow;
        
        %% Spatial domain basis images
        h = subplot(4, 4, c + 8);
        show_basis(Rec, K, h);
        
        subband(:) = 0;
        Y{iScale}{m}{n} = subband;
     
        c = c + 1;
    end
end

%%	This software is provided "as-is", without any express or implied
%%	warranty. In no event will the authors be held liable for any 
%%	damages arising from the use of this software.
