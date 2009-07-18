%% Generate a 3-D zoneplate image

function f_3D = zoneplate3D(half_width, freq, sampling)

if (nargin == 0)
    half_width = 51;
    freq = 40000;
    sampling = 0.0005;
elseif (nargin == 1)
    freq = 40000;
    sampling = 0.0005;
else
    sampling = 0.0005;
end

t = -(sampling * half_width):sampling:(sampling*half_width);

t_len = length(t);

X = repmat(t, [t_len, 1, t_len]);
Y = repmat(t', [1, t_len, t_len]);
Z = repmat(reshape(t,1,1,t_len), [t_len, t_len,1]);

f_3D = 1 - abs(cos( (X.^2 + Y.^2 + Z.^2)*freq));

f_3D = f_3D(1:end-1,1:end-1,1:end-1);

