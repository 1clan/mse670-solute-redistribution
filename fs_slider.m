function fs_slider
% FS_SLIDER  Interactive lever-rule graph for equilibrium solidification.
%
%   Move the solid-fraction slider from 0 to 1. The plot shows the
%   equilibrium solid and liquid compositions:
%
%       CS = k*C0 / (1 - (1-k)*fs)
%       CL =    C0 / (1 - (1-k)*fs)
%
%   where k is the partition coefficient and C0 is the nominal composition.
%
%   Assumptions: complete diffusion in both solid and liquid, local
%   equilibrium at the interface, constant k, closed system.
%
%   HOW TO RUN
%       Put this file in the Current Folder and run:  fs_slider
%
%   Requires MATLAB R2020a or newer (uifigure / uislider).
%
%   Default values (k = 0.30, C0 = 1.0 wt.%) are illustrative only.

C0 = 1.0;    % nominal composition, wt.%
k  = 0.30;   % equilibrium partition coefficient (0 < k <= 1)
fs0 = 0.50;  % initial solid fraction

%% UI
fig = uifigure('Name','Lever rule: composition vs solid fraction', ...
    'Color',[0.96 0.98 1.00], 'Position',[100 100 1050 660]);

g = uigridlayout(fig,[3 2]);
g.RowHeight = {40,'1x',104};
g.ColumnWidth = {350,'1x'};
g.Padding = [16 14 16 14];
g.RowSpacing = 12;
g.ColumnSpacing = 16;

head = uilabel(g);
head.Layout.Row = 1; head.Layout.Column = [1 2];
head.Text = 'SOLUTE REDISTRIBUTION  |  EQUILIBRIUM SOLIDIFICATION';
head.FontSize = 18; head.FontWeight = 'bold';
head.FontColor = [0.06 0.13 0.20];

% Control panel
ctrl = uigridlayout(g,[8 2]);
ctrl.Layout.Row = 2; ctrl.Layout.Column = 1;
ctrl.RowHeight = {36,42,34,34,58,26,'1x',22};
ctrl.ColumnWidth = {'1x',110};
ctrl.Padding = [0 0 0 0];
ctrl.RowSpacing = 8;

lblFs = uilabel(ctrl);
lblFs.Layout.Row = 1; lblFs.Layout.Column = 1;
lblFs.Text = 'Solid fraction, f_s';
lblFs.FontWeight = 'bold';

valFs = uilabel(ctrl);
valFs.Layout.Row = 1; valFs.Layout.Column = 2;
valFs.HorizontalAlignment = 'right';
valFs.FontWeight = 'bold';
valFs.FontColor = [0.06 0.45 0.42];

sld = uislider(ctrl,'Limits',[0 1],'Value',fs0);
sld.Layout.Row = 2; sld.Layout.Column = [1 2];
sld.MajorTicks = [0 0.25 0.50 0.75 1.00];
sld.MajorTickLabels = {'0','0.25','0.50','0.75','1.0'};
sld.MinorTicks = [];

lblK = uilabel(ctrl);
lblK.Layout.Row = 3; lblK.Layout.Column = 1;
lblK.Text = 'Partition coefficient, k';

kField = uieditfield(ctrl,'numeric','Limits',[0.01 1], ...
    'Value',k,'ValueDisplayFormat','%.2f');
kField.Layout.Row = 3; kField.Layout.Column = 2;

lblC0 = uilabel(ctrl);
lblC0.Layout.Row = 4; lblC0.Layout.Column = 1;
lblC0.Text = 'Nominal composition, C_0 (wt.%)';

c0Field = uieditfield(ctrl,'numeric','Limits',[0.01 100], ...
    'Value',C0,'ValueDisplayFormat','%.2f');
c0Field.Layout.Row = 4; c0Field.Layout.Column = 2;

eq = uilabel(ctrl);
eq.Layout.Row = 5; eq.Layout.Column = [1 2];
eq.Text = {'C_S = k C_0 / [1 - (1-k) f_s]', ...
           'C_L =     C_0 / [1 - (1-k) f_s]'};
eq.FontName = 'Consolas';
eq.FontSize = 13;
eq.HorizontalAlignment = 'center';
eq.BackgroundColor = [0.96 0.97 0.99];

note = uilabel(ctrl);
note.Layout.Row = 6; note.Layout.Column = [1 2];
note.Text = 'Complete diffusion in solid and liquid (equilibrium limit).';
note.FontSize = 11;
note.FontColor = [0.35 0.42 0.50];
note.WordWrap = 'on';

% Readout
readout = uitextarea(g,'Editable','off');
readout.Layout.Row = 3; readout.Layout.Column = 1;
readout.FontName = 'Consolas';
readout.FontSize = 11;
readout.BackgroundColor = [1 1 1];

% Axes: main composition-vs-fs chart on top, spatial profile below
right = uigridlayout(g,[2 1]);
right.Layout.Row = [2 3]; right.Layout.Column = 2;
right.RowHeight = {'3x','2x'};
right.Padding = [0 0 0 0];
right.RowSpacing = 8;

ax = uiaxes(right);
ax.Layout.Row = 1;
ax.FontSize = 11;
ax.Box = 'on';
ax.XGrid = 'on';
ax.YGrid = 'on';
ax.XLim = [0 1];
xlabel(ax,'Solid fraction, f_s');
ylabel(ax,'Concentration, C / C_0');
title(ax,'Composition vs. solid fraction');

axSpatial = uiaxes(right);
axSpatial.Layout.Row = 2;
axSpatial.FontSize = 10;
axSpatial.Box = 'on';
axSpatial.XGrid = 'on';
axSpatial.YGrid = 'on';
axSpatial.XLim = [0 1];
xlabel(axSpatial,'Position along bar, x / L');
ylabel(axSpatial,'C / C_0');
title(axSpatial,'Composition along the bar');

fsGrid = linspace(0,1,500);
csCurve = k*C0 ./ (1-(1-k)*fsGrid);
clCurve =    C0 ./ (1-(1-k)*fsGrid);

hold(ax,'on');
hCL = plot(ax,fsGrid,clCurve/C0,'--','LineWidth',1.8, ...
    'Color',[0.76 0.25 0.05],'DisplayName','Liquid, C_L');
hCS = plot(ax,fsGrid,csCurve/C0,'-','LineWidth',2.6, ...
    'Color',[0.06 0.46 0.43],'DisplayName','Solid, C_S');
hGuide = plot(ax,[fs0 fs0],[0 1],':','LineWidth',1.2, ...
    'Color',[0.15 0.30 0.55],'HandleVisibility','off');
hPtS = plot(ax,fs0,interp1(fsGrid,csCurve/C0,fs0),'o','MarkerSize',8, ...
    'MarkerFaceColor',[0.06 0.46 0.43],'MarkerEdgeColor','w', ...
    'HandleVisibility','off');
hPtL = plot(ax,fs0,interp1(fsGrid,clCurve/C0,fs0),'o','MarkerSize',8, ...
    'MarkerFaceColor',[0.76 0.25 0.05],'MarkerEdgeColor','w', ...
    'HandleVisibility','off');
legend(ax,'Location','northwest');
hold(ax,'off');

% Spatial profile: equilibrium gives a step between the uniform solid and
% liquid compositions at the interface position x/L = fs.
yTop0 = max(1/k,1)*1.06;
hold(axSpatial,'on');
hRegionS = patch(axSpatial,[0 fs0 fs0 0],[0 0 yTop0 yTop0], ...
    [0.06 0.46 0.43],'FaceAlpha',0.07,'EdgeColor','none');
hRegionL = patch(axSpatial,[fs0 1 1 fs0],[0 0 yTop0 yTop0], ...
    [0.90 0.55 0.15],'FaceAlpha',0.09,'EdgeColor','none');
hSpatialS = plot(axSpatial,[0 fs0],[k k],'-','LineWidth',3.0, ...
    'Color',[0.06 0.46 0.43]);
hSpatialL = plot(axSpatial,[fs0 1],[1 1],'--','LineWidth',2.4, ...
    'Color',[0.76 0.25 0.05]);
hSpatialGuide = plot(axSpatial,[fs0 fs0],[0 yTop0],':','LineWidth',1.2, ...
    'Color',[0.15 0.30 0.55]);
hSpatialPtS = plot(axSpatial,fs0,k,'o','MarkerSize',7, ...
    'MarkerFaceColor',[0.06 0.46 0.43],'MarkerEdgeColor','w');
hSpatialPtL = plot(axSpatial,fs0,1,'o','MarkerSize',7, ...
    'MarkerFaceColor',[0.76 0.25 0.05],'MarkerEdgeColor','w');
hold(axSpatial,'off');

% Initial render
updateDisplay();

sld.ValueChangingFcn = @(src,event) updateDisplay(event.Value);
sld.ValueChangedFcn  = @(src,event) updateDisplay(src.Value);
kField.ValueChangedFcn  = @(src,event) updateDisplay();
c0Field.ValueChangedFcn = @(src,event) updateDisplay();

    function updateDisplay(fsRequested)
        if nargin < 1 || isempty(fsRequested)
            fsRequested = sld.Value;
        end

        kNow  = kField.Value;
        c0Now = c0Field.Value;
        fsNow = max(0,min(1,fsRequested));

        den  = 1 - (1-kNow)*fsNow;
        csNow = kNow*c0Now/den;
        clNow =        c0Now/den;

        % Curves
        csNorm = kNow*c0Now ./ (1-(1-kNow)*fsGrid) / c0Now;
        clNorm =       c0Now ./ (1-(1-kNow)*fsGrid) / c0Now;
        set(hCS,'YData',csNorm);
        set(hCL,'YData',clNorm);

        % Current markers and guide
        csPt = kNow/den;
        clPt = 1/den;
        set(hPtS,'XData',fsNow,'YData',csPt);
        set(hPtL,'XData',fsNow,'YData',clPt);
        yTop = max(1/kNow,1)*1.06;
        set(hGuide,'XData',[fsNow fsNow],'YData',[0 yTop]);
        ylim(ax,[0 yTop]);

        % Spatial profile along the bar
        set(hRegionS,'XData',[0 fsNow fsNow 0],'YData',[0 0 yTop yTop]);
        set(hRegionL,'XData',[fsNow 1 1 fsNow],'YData',[0 0 yTop yTop]);
        set(hSpatialS,'XData',[0 fsNow],'YData',[csPt csPt]);
        set(hSpatialL,'XData',[fsNow 1],'YData',[clPt clPt]);
        set(hSpatialPtS,'XData',fsNow,'YData',csPt);
        set(hSpatialPtL,'XData',fsNow,'YData',clPt);
        set(hSpatialGuide,'XData',[fsNow fsNow],'YData',[0 yTop]);
        ylim(axSpatial,[0 yTop]);
        title(axSpatial,sprintf('Along bar: %.1f%% solid | %.1f%% liquid', ...
            100*fsNow,100*(1-fsNow)));

        % Text
        valFs.Text = sprintf('f_s = %.3f',fsNow);
        title(ax,sprintf('Composition at f_s = %.3f',fsNow));
        readout.Value = {
            sprintf('Solid   C_S = %.3f wt.%%   (C_S/C_0 = %.3f)',csNow,csPt)
            sprintf('Liquid  C_L = %.3f wt.%%   (C_L/C_0 = %.3f)',clNow,clPt)
            sprintf('Mass balance: %.6f wt.%%  (C_0 = %.3f)', ...
                fsNow*csNow + (1-fsNow)*clNow, c0Now)
            };
        drawnow limitrate;
    end
end
