function out = limited_liquid_model(k, c0, v, DL, fs, N, L)
%LIMITED_LIQUID_MODEL  No solid diffusion, limited liquid diffusion.
%
%   out = limited_liquid_model(k, c0, v, DL, fs)
%   out = limited_liquid_model(k, c0, v, DL, fs, N, L)
%
%   No solid diffusion (D_S = 0) and no liquid mixing (D_L finite). Solute
%   rejected by the growing solid can only spread by diffusion in the liquid,
%   so a boundary layer builds up ahead of the interface. With local
%   equilibrium at the interface, Cs* = k*Cl*.
%
%   At steady state the interface liquid composition reaches c0/k, the solid
%   grows at c0, and the liquid profile is
%
%       CL(z) = c0 + (Cl* - c0)*exp(-z/(delta/L)),
%       delta/L = DL/(v*L)
%
%   with boundary-layer thickness delta. The initial transient is governed by
%   (delta/L)/k, and near the end of the bar the boundary layer is squeezed
%   against the mold wall, producing a final-transient spike.
%
%   This implementation integrates the solid profile from the local
%   equilibrium condition and the global solute balance
%
%       integral_0^fs (Cs/c0) dx = fs - (1 - fs)*(Cl,avg/c0 - 1)
%
%   so the initial transient, the Cs = c0 plateau, and the final spike are
%   mass-conserving. The liquid boundary layer is reported separately.
%
%   Inputs
%       k    partition coefficient, k > 0 (not restricted to k <= 1)
%       c0   nominal composition
%       v    interface growth velocity (m/s)
%       DL   liquid diffusivity (m^2/s)
%       fs   solid fraction at which to evaluate the interface (default 0.5)
%       N    number of grid intervals (default 1400)
%       L    characteristic length (m, default 1e-3)
%
%   Outputs (struct)
%       out.x           solid position grid, 0 .. 0.9999
%       out.csProfile   solid composition Cs(x) along the bar
%       out.fs          requested solid fraction
%       out.delta       boundary-layer thickness, delta/L = DL/(v*L)
%       out.CsStar      interface solid composition at fs
%       out.ClStar      interface liquid composition at fs
%       out.CsAvg       average solid composition at fs
%       out.ClAvg       average liquid composition at fs
%       out.z           distance ahead of the interface, 0 .. (1-fs)
%       out.ClProfile   liquid boundary layer CL(z) at fs
%
%   The interface values are singular in the ideal no-mixing limit as
%   fs -> 1. The function returns Inf there rather than a finite artefact.
%
%   Example (Al-4.8 wt.% Cu at 648 C)
%       out = limited_liquid_model(0.173, 4.8, 20e-6, 2.4e-9, 0.5);
%       % default L = 1 mm; delta/L = 0.12

if nargin < 5 || isempty(fs)
    fs = 0.5;
end
if nargin < 6 || isempty(N)
    N = 1400;
end
if nargin < 7 || isempty(L)
    L = 1e-3;
end
if v <= 0
    error('limited_liquid_model:v','v must be positive.');
end
if DL <= 0
    error('limited_liquid_model:DL','DL must be positive.');
end
if L <= 0
    error('limited_liquid_model:L','L must be positive.');
end

delta = DL/(v*L);

fs = max(0, min(1, fs));
xmax = 0.9999;
dx = xmax/N;
x = (0:N)'*dx;
S = zeros(N+1,1);
I = zeros(N+1,1);
S(1) = k;

for i = 2:N+1
    xx = x(i);
    l = max(1 - xx, 1e-9);
    sPrev = S(i-1);
    s = sPrev;
    for it = 1:8
        Ii = I(i-1) + 0.5*(sPrev + s)*dx;
        deficit = xx - Ii;
        cStar = 1 + deficit/(delta*(1 - exp(-l/delta)));
        s = k*cStar;
    end
    S(i) = s;
    I(i) = I(i-1) + 0.5*(sPrev + s)*dx;
end

out.x = x;
out.csProfile = c0*S;
out.fs = fs;
out.delta = delta;

if fs >= 1 - 1e-12
    out.CsStar = Inf;
    out.ClStar = Inf;
    out.CsAvg = c0;
    out.ClAvg = Inf;
    out.z = 0;
    out.ClProfile = Inf;
    return;
end

xx = min(fs, xmax);
csStarN = interp1(x, S, xx);
Ii = interp1(x, I, xx);

out.CsStar = c0*csStarN;
out.ClStar = out.CsStar/k;

if fs < 1e-9
    out.CsAvg = k*c0;
    out.ClAvg = c0;
else
    out.CsAvg = c0*Ii/fs;
    out.ClAvg = c0*(1 - Ii)/(1 - fs);
end

out.z = linspace(0, 1 - fs, 140);
out.ClProfile = c0 + (out.ClStar - c0)*exp(-out.z/delta);
end
