function out = tiller_model(k, c0, Pe, fs, N)
%TILLER_MODEL  Diffusion-controlled planar solidification (Tiller et al.).
%
%   out = tiller_model(k, c0, Pe, fs)
%   out = tiller_model(k, c0, Pe, fs, N)
%
%   No solid diffusion (D_S = 0) and no liquid mixing (D_L finite). Solute
%   rejected by the growing solid can only spread by diffusion in the liquid,
%   so a boundary layer builds up ahead of the interface. With local
%   equilibrium at the interface, Cs* = k*Cl*.
%
%   At steady state the interface liquid composition reaches c0/k, the solid
%   grows at c0, and the liquid profile is
%
%       CL(z) = c0 + (Cl* - c0)*exp(-Pe*z),   Pe = v*L/D_L
%
%   with boundary-layer thickness delta/L = 1/Pe. The initial transient is
%   governed by 1/(k*Pe), and near the end of the bar the boundary layer is
%   squeezed against the mold wall, producing a final-transient spike.
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
%       Pe   Peclet number, Pe = v*L/D_L (use Pe >= 1 for a thin layer)
%       fs   solid fraction at which to evaluate the interface (default 0.5)
%       N    number of grid intervals (default 1400)
%
%   Outputs (struct)
%       out.x           solid position grid, 0 .. 0.9999
%       out.csProfile   solid composition Cs(x) along the bar
%       out.fs          requested solid fraction
%       out.Pe          Peclet number
%       out.delta       boundary-layer thickness, delta/L = 1/Pe
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
%   Example
%       out = tiller_model(0.3, 1.0, 20, 0.5);
%       % interface solid ~0.965, interface liquid ~3.217

if nargin < 4 || isempty(fs)
    fs = 0.5;
end
if nargin < 5 || isempty(N)
    N = 1400;
end
if Pe <= 0
    error('tiller_model:Pe','Pe must be positive.');
end

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
        cStar = 1 + deficit*Pe/(1 - exp(-Pe*l));
        s = k*cStar;
    end
    S(i) = s;
    I(i) = I(i-1) + 0.5*(sPrev + s)*dx;
end

out.x = x;
out.csProfile = c0*S;
out.fs = fs;
out.Pe = Pe;
out.delta = 1/Pe;

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
out.ClProfile = c0 + (out.ClStar - c0)*exp(-Pe*out.z);
end
