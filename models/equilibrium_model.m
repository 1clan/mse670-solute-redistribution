function [Cs, Cl, CsAvg, ClAvg] = equilibrium_model(k, c0, fs)
%EQUILIBRIUM_MODEL  Lever-rule solute redistribution (complete diffusion).
%
%   [Cs, Cl, CsAvg, ClAvg] = equilibrium_model(k, c0, fs)
%
%   Complete diffusion in both solid and liquid keeps both phases uniform.
%   Local equilibrium is k = Cs/Cl, and the lever rule gives
%
%       Cs = k*c0 / (1 - (1-k)*fs)
%       Cl =    c0 / (1 - (1-k)*fs)
%
%   Inputs
%       k   partition coefficient, k > 0 (not restricted to k <= 1)
%       c0  nominal composition
%       fs  solid fraction, 0 <= fs <= 1 (scalar or array)
%
%   Outputs
%       Cs      solid composition
%       Cl      liquid composition
%       CsAvg   average solid composition (= Cs for equilibrium)
%       ClAvg   average liquid composition (= Cl for equilibrium)
%
%   Example (Al-4.8 wt.% Cu)
%       [Cs, Cl] = equilibrium_model(0.173, 4.8, 0.5)   % Cs = 1.416, Cl = 8.184
%
%   HOW TO RUN
%       addpath('models')                 % from fs_slider_project
%       [Cs, Cl] = equilibrium_model(0.173, 4.8, 0.5);
%       fs = linspace(0,1,200);
%       [Cs, Cl] = equilibrium_model(0.173, 4.8, fs);   % vectorised
%
%   AUTHOR
%       Prathamesh Deepak Ladhe, MSE 670 -- Solidification
%
%   SEE ALSO
%       scheil_model, clyne_kurz_model, limited_liquid_model.
%       Derivation: report/TECHNICAL_REPORT.pdf, Section 2.2.

den = 1 - (1 - k).*fs;
Cs = (k .* c0) ./ den;
Cl = c0 ./ den;
CsAvg = Cs;
ClAvg = Cl;
end
