%% Display the 2-D magnitude frequency response the a 2-D image
%%
%% f: 2-D signal
%% K: resolution of the frequency plot
%% h: axes on which we plot.

function show_freq2D(f, N, h);

L = 2^ceil(log2(max([size(f), 512])));

f = abs(fftshift(fft2(f, L, L)));

ind = fix([1 : N] * L / N);

f = f(ind, ind);

fx = [-1 + 2/N : 2/N : 1];
fy = fx;

val = mesh(h, fx, fy, abs(f)');
axis([-1 1 -1 1 0 max(max(abs(f)))]);
view(0,90);
axis equal;