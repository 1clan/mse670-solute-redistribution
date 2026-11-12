function fs_slider
% FS_SLIDER  Interactive solute-redistribution slider for two solidification models.
%
%   Move the solid-fraction slider from 0 to 1. The plot shows the solid and
%   liquid compositions for the selected model:
%
%   Equilibrium (lever rule), complete diffusion in both phases:
%       CS = k*C0 / (1 - (1-k)*fs)
%       CL =    C0 / (1 - (1-k)*fs)
%
%   Scheil-Gulliver, no solid diffusion (D_S = 0), perfectly mixed liquid
%   (D_L -> inf), local equilibrium k = C_S/C_L:
%       CS = k*C0 * (1 - fs)^(k-1)
%       CL =    C0 * (1 - fs)^(k-1)
%
%   where k is the partition coefficient (k > 0) and C0 is the nominal
%   composition. A second axes shows the composition along the bar:
%   uniform phases for equilibrium, a cored solid profile for Scheil.
%
%   HOW TO RUN
%       Put this file in the Current Folder and run:  fs_slider
%
%   Requires MATLAB R2020a or newer (uifigure / uislider).
%
%   Default values (k = 0.30, C0 = 1.0 wt.%) are illustrative only.

C0 = 1.0;    % nominal composition, wt.%
k  = 0.30;   % partition coefficient (k > 0)
fs0 = 0.50;  % initial solid fraction

%% UI
fig = uifigure('Name','Solute redistribution: composition vs solid fraction', ...
    'Color',[0.96 0.98 1.00], 'Position',[100 100 1080 700]);

g = uigridlayout(fig,[3 2]);
g.RowHeight = {40,'1x',126};
g.ColumnWidth = {360,'1x'};
g.Padding = [16 14 16 14];
g.RowSpacing = 12;
g.ColumnSpacing = 16;

head = uilabel(g);
head.Layout.Row = 1; head.Layout.Column = [1 2];
head.Text = 'SOLUTE REDISTRIBUTION  |  EQUILIBRIUM';
head.FontSize = 18; head.FontWeight = 'bold';
head.FontColor = [0.06 0.13 0.20];

% Control panel
ctrl = uigridlayout(g,[8 2]);
ctrl.Layout.Row = 2; ctrl.Layout.Column = 1;
ctrl.RowHeight = {34,24,42,34,34,64,30,'1x'};
ctrl.ColumnWidth = {'1x',110};
ctrl.Padding = [0 0 0 0];
ctrl.RowSpacing = 8;

modelDrop = uidropdown(ctrl, ...
    'Items',{'Equilibrium (lever rule)','Scheil-Gulliver'}, ...
    'Value','Equilibrium (lever rule)');
modelDrop.Layout.Row = 1; modelDrop.Layout.Column = [1 2];

lblFs = uilabel(ctrl);
lblFs.Layout.Row = 2; lblFs.Layout.Column = 1;
lblFs.Text = 'Solid fraction, f_s';
lblFs.FontWeight = 'bold';

valFs = uilabel(ctrl);
valFs.Layout.Row = 2; valFs.Layout.Column = 2;
valFs.HorizontalAlignment = 'right';
valFs.FontWeight = 'bold';
valFs.FontColor = [0.06 0.45 0.42];

sld = uislider(ctrl,'Limits',[0 1],'Value',fs0);
sld.Layout.Row = 3; sld.Layout.Column = [1 2];
sld.MajorTicks = [0 0.25 0.50 0.75 1.00];
sld.MajorTickLabels = {'0','0.25','0.50','0.75','1.0'};
sld.MinorTicks = [];

lblK = uilabel(ctrl);
lblK.Layout.Row = 4; lblK.Layout.Column = 1;
lblK.Text = 'Partition coefficient, k  (k > 0)';

kField = uieditfield(ctrl,'numeric','Limits',[0.01 100], ...
    'Value',k,'ValueDisplayFormat','%.2f');
kField.Layout.Row = 4; kField.Layout.Column = 2;

lblC0 = uilabel(ctrl);
lblC0.Layout.Row = 5; lblC0.Layout.Column = 1;
lblC0.Text = 'Nominal composition, C_0 (wt.%)';

c0Field = uieditfield(ctrl,'numeric','Limits',[0.01 100], ...
    'Value',C0,'ValueDisplayFormat','%.2f');
c0Field.Layout.Row = 5; c0Field.Layout.Column = 2;

eq = uilabel(ctrl);
eq.Layout.Row = 6; eq.Layout.Column = [1 2];
eq.Text = {'C_S = k C_0 / [1 - (1-k) f_s]', ...
           'C_L =     C_0 / [1 - (1-k) f_s]'};
eq.FontName = 'Consolas';
eq.FontSize = 13;
eq.HorizontalAlignment = 'center';
eq.BackgroundColor = [0.96 0.97 0.99];

note = uilabel(ctrl);
note.Layout.Row = 7; note.Layout.Column = [1 2];
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
% liquid compositions; Scheil gives a cored solid profile.
yTop0 = max([1, k, 1/k])*1.06;
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
modelDrop.ValueChangedFcn = @(src,event) updateDisplay();
kField.ValueChangedFcn    = @(src,event) updateDisplay();
c0Field.ValueChangedFcn   = @(src,event) updateDisplay();

    function tf = isScheil()
        tf = (modelDrop.ValueIndex == 2);
    end

    function [csVal, clVal] = modelValues(fsVal, kVal, c0Val)
        if isScheil()
            base  = (1 - fsVal).^(kVal - 1);
            clVal = c0Val * base;
            csVal = kVal * clVal;
        else
            den   = 1 - (1 - kVal) * fsVal;
            csVal = kVal * c0Val ./ den;
            clVal = c0Val ./ den;
        end
    end

    function avg = csAvgAt(fsVal, kVal, c0Val)
        if ~isScheil()
            [avg, ~] = modelValues(fsVal, kVal, c0Val);
        elseif fsVal < 1e-9
            avg = kVal * c0Val;
        else
            avg = c0Val * (1 - (1 - fsVal)^kVal) / fsVal;
        end
    end

    function top = yTopFor(kVal)
        if isScheil()
            if kVal < 1
                % Scheil diverges at fs = 1 for k < 1; cap the view around
                % fs = 0.95 so the early part of the curve stays readable.
                top = max([1, 0.05^(kVal - 1)])*1.06;
            else
                top = max([1, kVal])*1.06;
            end
        else
            top = max([1, kVal, 1/kVal])*1.06;
        end
    end

    function vals = solidProfileAt(x, kVal, c0Val, fsNow)
        if isScheil()
            vals = kVal * c0Val * (1 - x).^(kVal - 1);
        else
            [csNow, ~] = modelValues(fsNow, kVal, c0Val);
            vals = csNow * ones(size(x));
        end
    end

    function s = fmtNum(v)
        if isinf(v)
            s = char(8734);            % infinity symbol
        elseif isnan(v)
            s = char(8212);            % em dash
        else
            s = sprintf('%.3f', v);
        end
    end

    function updateDisplay(fsRequested)
        if nargin < 1 || isempty(fsRequested)
            fsRequested = sld.Value;
        end

        kNow  = kField.Value;
        c0Now = c0Field.Value;
        fsNow = max(0, min(1, fsRequested));
        scheil = isScheil();
        singular = scheil && kNow < 1 && fsNow > 1 - 1e-9;

        [csNow, clNow] = modelValues(fsNow, kNow, c0Now);
        csAvgNow = csAvgAt(fsNow, kNow, c0Now);

        % Curves (non-finite points are skipped so Inf/NaN are not drawn)
        [csCurve, clCurve] = modelValues(fsGrid, kNow, c0Now);
        csCurve(~isfinite(csCurve)) = NaN;
        clCurve(~isfinite(clCurve)) = NaN;
        set(hCS,'YData',csCurve/c0Now);
        set(hCL,'YData',clCurve/c0Now);

        % Current markers and guide
        csPt = csNow/c0Now;
        clPt = clNow/c0Now;
        if ~isfinite(csPt), csPt = NaN; end
        if ~isfinite(clPt), clPt = NaN; end
        set(hPtS,'XData',fsNow,'YData',csPt);
        set(hPtL,'XData',fsNow,'YData',clPt);

        yTop = yTopFor(kNow);
        set(hGuide,'XData',[fsNow fsNow],'YData',[0 yTop]);
        ylim(ax,[0 yTop]);

        % Spatial profile along the bar
        set(hRegionS,'XData',[0 fsNow fsNow 0],'YData',[0 0 yTop yTop]);
        set(hRegionL,'XData',[fsNow 1 1 fsNow],'YData',[0 0 yTop yTop]);

        if fsNow < 1e-9
            xSolid = [0 0];
        else
            xSolid = linspace(0, fsNow, 180);
        end
        ySolid = solidProfileAt(xSolid, kNow, c0Now, fsNow)/c0Now;
        ySolid(~isfinite(ySolid)) = NaN;
        set(hSpatialS,'XData',xSolid,'YData',ySolid);

        if fsNow < 1 - 1e-9 && isfinite(clPt)
            set(hSpatialL,'XData',[fsNow 1],'YData',[clPt clPt]);
            set(hSpatialPtL,'XData',fsNow,'YData',clPt);
        else
            set(hSpatialL,'XData',NaN,'YData',NaN);
            set(hSpatialPtL,'XData',NaN,'YData',NaN);
        end

        set(hSpatialPtS,'XData',fsNow,'YData',csPt);
        set(hSpatialGuide,'XData',[fsNow fsNow],'YData',[0 yTop]);
        ylim(axSpatial,[0 yTop]);

        % Labels and readout
        if scheil
            head.Text = 'SOLUTE REDISTRIBUTION  |  SCHEIL-GULLIVER';
            eq.Text = {'C_S = k C_0 (1 - f_s)^(k-1)', ...
                       'C_L =     C_0 (1 - f_s)^(k-1)'};
            note.Text = ['No solid diffusion (D_S = 0), perfectly mixed ' ...
                'liquid (D_L -> inf), local equilibrium k = C_S/C_L.'];
            hCS.DisplayName = 'Solid (interface), C_S';
            title(axSpatial,sprintf('Along bar: cored solid | %.1f%% solid', ...
                100*fsNow));
            if singular
                balanceText = sprintf( ...
                    'Mass balance: singular at f_s = 1 (C_L -> inf)');
            else
                balance = fsNow*csAvgNow + (1-fsNow)*clNow;
                balanceText = sprintf('Mass balance: %.6f wt.%%  (C_0 = %.3f)', ...
                    balance, c0Now);
            end
            readout.Value = {
                'Model   Scheil-Gulliver (D_S = 0, D_L -> inf)'
                sprintf('Solid (interface)  C_S* = %s wt.%%',fmtNum(csNow))
                sprintf('Average solid      C_S,avg = %s wt.%%',fmtNum(csAvgNow))
                sprintf('Liquid             C_L = %s wt.%%',fmtNum(clNow))
                balanceText
                };
        else
            head.Text = 'SOLUTE REDISTRIBUTION  |  EQUILIBRIUM';
            eq.Text = {'C_S = k C_0 / [1 - (1-k) f_s]', ...
                       'C_L =     C_0 / [1 - (1-k) f_s]'};
            note.Text = 'Complete diffusion in solid and liquid (equilibrium limit).';
            hCS.DisplayName = 'Solid, C_S';
            title(axSpatial,sprintf('Along bar: %.1f%% solid | %.1f%% liquid', ...
                100*fsNow,100*(1-fsNow)));
            balance = fsNow*csNow + (1-fsNow)*clNow;
            readout.Value = {
                'Model   Equilibrium (lever rule)'
                sprintf('Solid   C_S = %s wt.%%',fmtNum(csNow))
                sprintf('Liquid  C_L = %s wt.%%',fmtNum(clNow))
                sprintf('Mass balance: %.6f wt.%%  (C_0 = %.3f)', ...
                    balance, c0Now)
                };
        end

        valFs.Text = sprintf('f_s = %.3f',fsNow);
        title(ax,sprintf('Composition at f_s = %.3f',fsNow));
        drawnow limitrate;
    end
end
