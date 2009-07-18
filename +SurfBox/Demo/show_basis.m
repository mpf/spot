%% Display the 2-D basis image
%%
%% f: 2-D signal
%% K: resolution of the basis image
%% h: axes on which we plot.

function show_basis(f, N, h);

MaxVal = max(abs(f(:)));
[R, C] = find(abs(f) == MaxVal);

f = f ./ MaxVal;

f = f(R(1) - N / 2 + 1 : R(1) + N / 2, C(1) - N / 2 + 1 : C(1) + N / 2);
dx = [-1 + 2/N : 2/N : 1];
dy = dx;

val = mesh(h, dy, dy, f);
axis([-1 1 -1 1 -1 1]);
view(0,90);
axis equal;