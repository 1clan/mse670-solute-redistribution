function fs_slider
% FS_SLIDER  Interactive solute-redistribution slider for four solidification models.
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
%   No solid diffusion, limited liquid diffusion (diffusion-controlled planar growth)
%   and no liquid mixing. A boundary layer builds up ahead of the interface:
%       CS(x) = C0*[k + (1-k)(1 - exp(-k*x/(delta/L)))]   (initial transient)
%       CS    = C0                                        (steady growth)
%       CL(z) = C0*[1 + (1-k)/k * exp(-z/(delta/L))]
%       delta/L = D_L/(v*L),  L = 1 mm
%
%   Clyne-Kurz (finite solid back diffusion, mixed liquid):
%       CL/C0 = [1 - (1-beta*k)*fs]^((k-1)/(1-beta*k))
%       beta  = 2*alpha*(1-exp(-1/alpha)) - exp(-1/(2*alpha))
%       alpha = 4*Ds*tf/lambda2^2
%   The Won-Thomas option replaces alpha by alpha+ = 2*(alpha + alpha_C).
%   beta can also be entered directly as a sensitivity parameter.
%
%   A second axes shows the composition along the bar. k is unrestricted
%   (k > 0); it is not limited to 0 < k <= 1.
%
%   The browser version at index.html also exposes logarithmic k and C_0
%   sliders and a Play button for every parameter. This app mirrors them:
%   k and C_0 each have a slider plus an editable numeric field, and the
%   four triangular buttons animate f_s, T, k or C_0 back and forth.
%
%   HOW TO RUN
%       Put this file in the Current Folder and run:  fs_slider
%
%   Requires MATLAB R2020a or newer (uifigure / uislider).
%
%   Default material: Al-4.8 wt.% Cu. The temperature slider moves the
%   liquidus tie-line and rescales k, D_s and D_L from the phase diagram
%   and Arrhenius fits anchored at 648 C.

% Al-4.8 wt.% Cu reference properties
Tm       = 660.3;    % melting point of pure Al, C
Tref     = 648;      % liquidus temperature of the alloy, C
Teut     = 548;      % solidus / eutectic temperature, C
kRef     = 0.173;    % partition coefficient at Tref
dsRef    = 4.8e-15;  % solid diffusivity at Tref, m^2/s
dlRef    = 2.4e-9;   % liquid diffusivity at Tref, m^2/s
Qs       = 130e3;    % solid activation energy, J/mol
Ql       = 30e3;     % liquid activation energy, J/mol
Rgas     = 8.314462618;

C0   = 4.8;    % nominal composition, wt.%
k    = kRef;   % partition coefficient (k > 0)
fs0  = 0.50;   % initial solid fraction
T0   = Tref;   % interface temperature, C

% Model parameters
v0       = 20;       % growth velocity, um/s
dl0      = 2.4;      % liquid diffusivity, units of 1e-9 m^2/s
L0       = 1e-3;     % characteristic length, m (1 mm)
ds0      = 0.0048;   % solid diffusivity, units of 1e-12 m^2/s
tf0      = 100;      % local solidification time, s
lambda20 = 20;       % secondary dendrite arm spacing, microns
alphaC0  = 0.10;     % Won-Thomas coarsening constant
beta0    = 0.0096;   % direct Clyne-Kurz beta (when override is enabled)

solidColor  = [0.06 0.46 0.43];
liquidColor = [0.76 0.25 0.05];
guideColor  = [0.15 0.30 0.55];

%% UI
fig = uifigure('Name','Solute redistribution: four solidification models', ...
    'Color',[0.96 0.98 1.00], 'Position',[60 30 1180 1000]);

g = uigridlayout(fig,[3 2]);
g.RowHeight = {40,'1x',150};
g.ColumnWidth = {380,'1x'};
g.Padding = [16 14 16 14];
g.RowSpacing = 12;
g.ColumnSpacing = 16;

head = uilabel(g);
head.Layout.Row = 1; head.Layout.Column = [1 2];
head.Text = 'SOLUTE REDISTRIBUTION  |  EQUILIBRIUM';
head.FontSize = 18; head.FontWeight = 'bold';
head.FontColor = [0.06 0.13 0.20];

% Control panel
ctrl = uigridlayout(g,[15 3]);
ctrl.Layout.Row = 2; ctrl.Layout.Column = 1;
ctrl.RowHeight = {32,22,42,34,26,20,42,30,30,30,30,0,28,60,34};
ctrl.ColumnWidth = {'1x',96,34};
ctrl.Padding = [0 0 0 0];
ctrl.RowSpacing = 6;

modelDrop = uidropdown(ctrl, ...
    'Items',{'Equilibrium (lever rule)', ...
             'Scheil-Gulliver', ...
             'No solid diffusion, limited liquid diffusion', ...
             'Clyne-Kurz (back diffusion)'}, ...
    'Value','Equilibrium (lever rule)');
modelDrop.Layout.Row = 1; modelDrop.Layout.Column = [1 3];

lblT = uilabel(ctrl);
lblT.Layout.Row = 2; lblT.Layout.Column = 1;
lblT.Text = 'Interface temperature, T (C)';
lblT.FontWeight = 'bold';

valT = uilabel(ctrl);
valT.Layout.Row = 2; valT.Layout.Column = 2;
valT.HorizontalAlignment = 'right';
valT.FontWeight = 'bold';
valT.FontColor = liquidColor;

btnPlayT = uibutton(ctrl,'push','Text',char(9654),'FontSize',11);
btnPlayT.Layout.Row = 2; btnPlayT.Layout.Column = 3;
btnPlayT.Tooltip = 'Animate T from 548 to 700 C and back';

tempSld = uislider(ctrl,'Limits',[Teut 700],'Value',T0);
tempSld.Layout.Row = 3; tempSld.Layout.Column = [1 3];
tempSld.MajorTicks = [Teut 600 648 700];
tempSld.MajorTickLabels = {'548','600','648','700'};
tempSld.MinorTicks = [];

tieLbl = uilabel(ctrl);
tieLbl.Layout.Row = 4; tieLbl.Layout.Column = [1 3];
tieLbl.Text = 'Liquidus tie-line: C_L = 4.80, C_S = 0.830 wt.%';
tieLbl.FontSize = 11;
tieLbl.FontColor = [0.22 0.30 0.40];
tieLbl.WordWrap = 'on';

tempLinkCheck = uicheckbox(ctrl, ...
    'Text','Derive k, D_s and D_L from T','Value',true);
tempLinkCheck.Layout.Row = 5; tempLinkCheck.Layout.Column = [1 3];

lblFs = uilabel(ctrl);
lblFs.Layout.Row = 6; lblFs.Layout.Column = 1;
lblFs.Text = 'Solid fraction, f_s';
lblFs.FontWeight = 'bold';

valFs = uilabel(ctrl);
valFs.Layout.Row = 6; valFs.Layout.Column = 2;
valFs.HorizontalAlignment = 'right';
valFs.FontWeight = 'bold';
valFs.FontColor = solidColor;

btnPlayFs = uibutton(ctrl,'push','Text',char(9654),'FontSize',11);
btnPlayFs.Layout.Row = 6; btnPlayFs.Layout.Column = 3;
btnPlayFs.Tooltip = 'Animate f_s from 0 to 1 and back';

sld = uislider(ctrl,'Limits',[0 1],'Value',fs0);
sld.Layout.Row = 7; sld.Layout.Column = [1 3];
sld.MajorTicks = [0 0.25 0.50 0.75 1.00];
sld.MajorTickLabels = {'0','0.25','0.50','0.75','1.0'};
sld.MinorTicks = [];

lblK = uilabel(ctrl);
lblK.Layout.Row = 8; lblK.Layout.Column = 1;
lblK.Text = 'Partition coefficient, k (log slider)';

kField = uieditfield(ctrl,'numeric','Limits',[0.01 100], ...
    'Value',k,'ValueDisplayFormat','%.4f');
kField.Layout.Row = 8; kField.Layout.Column = 2;

btnPlayK = uibutton(ctrl,'push','Text',char(9654),'FontSize',11);
btnPlayK.Layout.Row = 8; btnPlayK.Layout.Column = 3;
btnPlayK.Tooltip = 'Animate k over 0.01-100 and turn off temperature coupling';

logMin = 0.01;
logMax = 100;
kSld = uislider(ctrl,'Limits',[0 1], ...
    'Value',(log10(k) - log10(logMin))/(log10(logMax) - log10(logMin)));
kSld.Layout.Row = 9; kSld.Layout.Column = [1 3];
kSld.MajorTicks = [0 0.25 0.50 0.75 1];
kSld.MajorTickLabels = {'0.01','0.1','1','10','100'};
kSld.MinorTicks = [];

lblC0 = uilabel(ctrl);
lblC0.Layout.Row = 10; lblC0.Layout.Column = 1;
lblC0.Text = 'Nominal composition, C_0 (log slider)';

c0Field = uieditfield(ctrl,'numeric','Limits',[0.01 100], ...
    'Value',C0,'ValueDisplayFormat','%.2f');
c0Field.Layout.Row = 10; c0Field.Layout.Column = 2;

btnPlayC0 = uibutton(ctrl,'push','Text',char(9654),'FontSize',11);
btnPlayC0.Layout.Row = 10; btnPlayC0.Layout.Column = 3;
btnPlayC0.Tooltip = 'Animate C_0 over 0.01-100 wt.%';

c0Sld = uislider(ctrl,'Limits',[0 1], ...
    'Value',(log10(C0) - log10(logMin))/(log10(logMax) - log10(logMin)));
c0Sld.Layout.Row = 11; c0Sld.Layout.Column = [1 3];
c0Sld.MajorTicks = [0 0.25 0.50 0.75 1];
c0Sld.MajorTickLabels = {'0.01','0.1','1','10','100'};
c0Sld.MinorTicks = [];

% Model-specific parameter panel
pg = uigridlayout(ctrl,[8 2]);
pg.Layout.Row = 12; pg.Layout.Column = [1 3];
pg.RowHeight = {30,30,30,30,30,30,26,30};
pg.ColumnWidth = {'1x',120};
pg.Padding = [0 0 0 0];
pg.RowSpacing = 4;
pg.Visible = 'off';

vLbl = uilabel(pg);
vLbl.Layout.Row = 1; vLbl.Layout.Column = 1;
vLbl.Text = 'Growth velocity, v (um/s)';
vField = uieditfield(pg,'numeric','Limits',[0.01 100000], ...
    'Value',v0,'ValueDisplayFormat','%.4g');
vField.Layout.Row = 1; vField.Layout.Column = 2;

dlLbl = uilabel(pg);
dlLbl.Layout.Row = 2; dlLbl.Layout.Column = 1;
dlLbl.Text = 'D_L (x10^-9 m^2/s)';
dlField = uieditfield(pg,'numeric','Limits',[0.0001 1000], ...
    'Value',dl0,'ValueDisplayFormat','%.4g');
dlField.Layout.Row = 2; dlField.Layout.Column = 2;

dsLbl = uilabel(pg);
dsLbl.Layout.Row = 3; dsLbl.Layout.Column = 1;
dsLbl.Text = 'D_s (x10^-12 m^2/s)';
dsField = uieditfield(pg,'numeric','Limits',[0 1000], ...
    'Value',ds0,'ValueDisplayFormat','%.4g');
dsField.Layout.Row = 3; dsField.Layout.Column = 2;

tfLbl = uilabel(pg);
tfLbl.Layout.Row = 4; tfLbl.Layout.Column = 1;
tfLbl.Text = 'Solidification time, t_f (s)';
tfField = uieditfield(pg,'numeric','Limits',[0 100000], ...
    'Value',tf0,'ValueDisplayFormat','%.4g');
tfField.Layout.Row = 4; tfField.Layout.Column = 2;

lamLbl = uilabel(pg);
lamLbl.Layout.Row = 5; lamLbl.Layout.Column = 1;
lamLbl.Text = 'Arm spacing, lambda_2 (microns)';
lamField = uieditfield(pg,'numeric','Limits',[0.01 10000], ...
    'Value',lambda20,'ValueDisplayFormat','%.4g');
lamField.Layout.Row = 5; lamField.Layout.Column = 2;

aCLbl = uilabel(pg);
aCLbl.Layout.Row = 6; aCLbl.Layout.Column = 1;
aCLbl.Text = 'Won-Thomas constant, alpha_C';
aCField = uieditfield(pg,'numeric','Limits',[0 10], ...
    'Value',alphaC0,'ValueDisplayFormat','%.3f');
aCField.Layout.Row = 6; aCField.Layout.Column = 2;

wtCheck = uicheckbox(pg,'Text','Won-Thomas: alpha+ = 2(alpha + alpha_C)', ...
    'Value',false);
wtCheck.Layout.Row = 7; wtCheck.Layout.Column = [1 2];

betaCheck = uicheckbox(pg,'Text','Use beta directly','Value',false);
betaCheck.Layout.Row = 8; betaCheck.Layout.Column = 1;
betaField = uieditfield(pg,'numeric','Limits',[0 1], ...
    'Value',beta0,'ValueDisplayFormat','%.4f');
betaField.Layout.Row = 8; betaField.Layout.Column = 2;

lblView = uilabel(ctrl);
lblView.Layout.Row = 13; lblView.Layout.Column = 1;
lblView.Text = 'Graph view';

viewDrop = uidropdown(ctrl, ...
    'Items',{'Auto zoom','Fixed scale'},'Value','Auto zoom');
viewDrop.Layout.Row = 13; viewDrop.Layout.Column = 2;

eq = uilabel(ctrl);
eq.Layout.Row = 14; eq.Layout.Column = [1 3];
eq.Text = {'C_S = k C_0 / [1 - (1-k) f_s]', ...
           'C_L =     C_0 / [1 - (1-k) f_s]'};
eq.FontName = 'Consolas';
eq.FontSize = 11;
eq.Interpreter = 'tex';
eq.HorizontalAlignment = 'center';
eq.BackgroundColor = [0.96 0.97 0.99];

note = uilabel(ctrl);
note.Layout.Row = 15; note.Layout.Column = [1 3];
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

fsGrid = linspace(0,1,600);
bandColors = {[0.95 0.75 0.20],[0.20 0.65 0.45],[0.90 0.50 0.15]};
bandNames = {'initial','steady','final'};

hold(ax,'on');
hBand = gobjects(1,3);
hBandText = gobjects(1,3);
for ib = 1:3
    hBand(ib) = patch(ax,[0 0 0 0],[0 0 1 1],bandColors{ib}, ...
        'FaceAlpha',0.10,'EdgeColor','none','HandleVisibility','off', ...
        'Visible','off');
end
hCL = plot(ax,fsGrid,ones(size(fsGrid)),'--','LineWidth',1.8, ...
    'Color',liquidColor,'DisplayName','Liquid, C_L');
hCS = plot(ax,fsGrid,ones(size(fsGrid)),'-','LineWidth',2.6, ...
    'Color',solidColor,'DisplayName','Solid, C_S');
hGuide = plot(ax,[fs0 fs0],[0 1],':','LineWidth',1.2, ...
    'Color',guideColor,'HandleVisibility','off');
hPtS = plot(ax,fs0,1,'o','MarkerSize',8, ...
    'MarkerFaceColor',solidColor,'MarkerEdgeColor','w', ...
    'HandleVisibility','off');
hPtL = plot(ax,fs0,1,'o','MarkerSize',8, ...
    'MarkerFaceColor',liquidColor,'MarkerEdgeColor','w', ...
    'HandleVisibility','off');
for ib = 1:3
    hBandText(ib) = text(ax,0.5,0.5,bandNames{ib}, ...
        'HorizontalAlignment','center','FontSize',9, ...
        'Color',[0.45 0.38 0.22],'Visible','off');
end
legend(ax,'Location','northwest');
hold(ax,'off');

% Spatial profile
yTop0 = 2;
hold(axSpatial,'on');
hRegionS = patch(axSpatial,[0 0 0 0],[0 0 yTop0 yTop0], ...
    solidColor,'FaceAlpha',0.07,'EdgeColor','none');
hRegionL = patch(axSpatial,[0 1 1 0],[0 0 yTop0 yTop0], ...
    [0.90 0.55 0.15],'FaceAlpha',0.09,'EdgeColor','none');
hSpatialS = plot(axSpatial,[0 0],[0 0],'-','LineWidth',3.0,'Color',solidColor);
hSpatialL = plot(axSpatial,[0 1],[0 0],'--','LineWidth',2.4,'Color',liquidColor);
hDelta = plot(axSpatial,[0 0],[0 0],'-','LineWidth',1.2, ...
    'Color',[0.55 0.60 0.66],'Visible','off');
hDeltaTick1 = plot(axSpatial,[0 0],[0 0],'-','LineWidth',1.2, ...
    'Color',[0.55 0.60 0.66],'Visible','off');
hDeltaTick2 = plot(axSpatial,[0 0],[0 0],'-','LineWidth',1.2, ...
    'Color',[0.55 0.60 0.66],'Visible','off');
hAvgLink = plot(axSpatial,[0 0],[0 0],'--','LineWidth',1.3, ...
    'Color',solidColor,'Visible','off');
hSpatialGuide = plot(axSpatial,[fs0 fs0],[0 yTop0],':','LineWidth',1.2, ...
    'Color',guideColor);
hConnS = plot(axSpatial,[0 0],[0 0],'-','LineWidth',2.8,'Color',solidColor, ...
    'HandleVisibility','off');
hConnL = plot(axSpatial,[0 0],[0 0],'-','LineWidth',2.8,'Color',liquidColor, ...
    'HandleVisibility','off');
hSpatialPtS = plot(axSpatial,fs0,1,'o','MarkerSize',7, ...
    'MarkerFaceColor',solidColor,'MarkerEdgeColor','w');
hSpatialPtL = plot(axSpatial,fs0,1,'o','MarkerSize',7, ...
    'MarkerFaceColor',liquidColor,'MarkerEdgeColor','w');
hDeltaText = text(axSpatial,0.5,0.1,'','HorizontalAlignment','center', ...
    'FontSize',9,'Color',[0.40 0.45 0.52],'Visible','off');
hold(axSpatial,'off');

% limited-liquid profile cache
limitedKey = '';
limitedX = [];
limitedS = [];
limitedI = [];

% Temperature shown by the slider (event.Value during live dragging)
tempDisplay = T0;

% Play-animation state: one parameter animates at a time.
animTarget = '';
animDir = 1;
animPos = 0;
animTimer = [];

% Initial render
updatePanelLayout();
updateDisplay();

sld.ValueChangingFcn = @(src,event) manualFs(event.Value);
sld.ValueChangedFcn  = @(src,event) manualFs(src.Value);
tempSld.ValueChangingFcn = @(src,event) manualTemp(event.Value);
tempSld.ValueChangedFcn  = @(src,event) manualTemp(event.Value);
tempLinkCheck.ValueChangedFcn = @(src,event) onTempLinkChanged();
modelDrop.ValueChangedFcn = @(src,event) onModelChanged();
kField.ValueChangedFcn    = @(src,event) onKFieldChanged();
c0Field.ValueChangedFcn   = @(src,event) onC0FieldChanged();
kSld.ValueChangingFcn     = @(src,event) onKSldChanged(event.Value);
kSld.ValueChangedFcn      = @(src,event) onKSldChanged(src.Value);
c0Sld.ValueChangingFcn    = @(src,event) onC0SldChanged(event.Value);
c0Sld.ValueChangedFcn     = @(src,event) onC0SldChanged(src.Value);
vField.ValueChangedFcn    = @(src,event) onOtherControlChanged();
dlField.ValueChangedFcn   = @(src,event) onOtherControlChanged();
dsField.ValueChangedFcn   = @(src,event) onOtherControlChanged();
tfField.ValueChangedFcn   = @(src,event) onOtherControlChanged();
lamField.ValueChangedFcn  = @(src,event) onOtherControlChanged();
aCField.ValueChangedFcn   = @(src,event) onOtherControlChanged();
wtCheck.ValueChangedFcn   = @(src,event) onOtherControlChanged();
betaField.ValueChangedFcn = @(src,event) onOtherControlChanged();
betaCheck.ValueChangedFcn = @(src,event) onOtherControlChanged();
viewDrop.ValueChangedFcn  = @(src,event) onOtherControlChanged();
btnPlayFs.ButtonPushedFcn = @(src,event) toggleAnim('fs');
btnPlayT.ButtonPushedFcn  = @(src,event) toggleAnim('T');
btnPlayK.ButtonPushedFcn  = @(src,event) toggleAnim('k');
btnPlayC0.ButtonPushedFcn = @(src,event) toggleAnim('c0');
fig.CloseRequestFcn       = @(src,event) onClose();

    function manualFs(v)
        stopAnim();
        updateDisplay(v);
    end

    function manualTemp(Tnew)
        stopAnim();
        updateTemperature(Tnew);
    end

    function onTempLinkChanged()
        stopAnim();
        updateDisplay();
    end

    function onKFieldChanged()
        stopAnim();
        % Typing a value is a manual override: stop deriving k from T.
        if tempLinkCheck.Value
            tempLinkCheck.Value = false;
        end
        updateDisplay();
    end

    function onC0FieldChanged()
        stopAnim();
        updateDisplay();
    end

    function onKSldChanged(p)
        stopAnim();
        if tempLinkCheck.Value
            tempLinkCheck.Value = false;
        end
        kField.Value = min(logMax,max(logMin,logVal(p)));
        updateDisplay();
    end

    function onC0SldChanged(p)
        stopAnim();
        c0Field.Value = min(logMax,max(logMin,logVal(p)));
        updateDisplay();
    end

    function onOtherControlChanged()
        stopAnim();
        updateDisplay();
    end


    function tf = isScheil()
        tf = (modelDrop.ValueIndex == 2);
    end

    function tf = isLimitedLiquid()
        tf = (modelDrop.ValueIndex == 3);
    end

    function tf = isCK()
        tf = (modelDrop.ValueIndex == 4);
    end

    function tf = isFixedView()
        tf = strcmp(viewDrop.Value,'Fixed scale');
    end

    function onModelChanged()
        stopAnim();
        updatePanelLayout();
        updateDisplay();
    end

    function updateTemperature(Tnew)
        tempDisplay = Tnew;
        updateDisplay();
    end

    % ── Parameter animation ────────────────────────────────
    % The four triangular buttons sweep one parameter between the ends of
    % its range and back. A timer drives the motion; starting any button
    % stops the previous animation, and any manual edit also stops it.
    function p = logPos(v)
        p = (log10(min(logMax,max(logMin,v))) - log10(logMin)) / ...
            (log10(logMax) - log10(logMin));
        p = max(0,min(1,p));
    end

    function v = logVal(p)
        p = max(0,min(1,p));
        v = 10^(log10(logMin) + p*(log10(logMax) - log10(logMin)));
    end

    function p = paramPos(target)
        switch target
            case 'fs'
                p = sld.Value;
            case 'T'
                p = (tempDisplay - Teut)/(700 - Teut);
            case 'k'
                p = logPos(kField.Value);
            case 'c0'
                p = logPos(c0Field.Value);
            otherwise
                p = 0;
        end
        p = max(0,min(1,p));
    end

    function syncParamSliders()
        kSld.Value = logPos(kField.Value);
        c0Sld.Value = logPos(c0Field.Value);
    end

    function updateAnimButtons()
        btns = [btnPlayFs btnPlayT btnPlayK btnPlayC0];
        tgts = {'fs','T','k','c0'};
        for ibtn = 1:numel(btns)
            if strcmp(animTarget,tgts{ibtn})
                btns(ibtn).Text = '||';
            else
                btns(ibtn).Text = char(9654);
            end
        end
    end

    function stopAnim()
        if ~isempty(animTimer) && isvalid(animTimer)
            stop(animTimer);
        end
        animTarget = '';
        updateAnimButtons();
    end

    function toggleAnim(target)
        if strcmp(animTarget,target)
            stopAnim();
            return;
        end
        stopAnim();
        animTarget = target;
        animPos = paramPos(target);
        animDir = 1;
        if animPos >= 1 - 1e-9
            animDir = -1;
        end
        % Animating k is a manual override, just like dragging its slider.
        if strcmp(target,'k') && tempLinkCheck.Value
            tempLinkCheck.Value = false;
        end
        if isempty(animTimer) || ~isvalid(animTimer)
            animTimer = timer('ExecutionMode','fixedSpacing','Period',0.05, ...
                'BusyMode','drop','TimerFcn',@(src,event) animStep());
        end
        updateAnimButtons();
        start(animTimer);
    end

    function animStep()
        if isempty(animTarget)
            stopAnim();
            return;
        end
        animPos = animPos + animDir*0.05*0.18;
        if animPos >= 1
            animPos = 1;
            animDir = -1;
        elseif animPos <= 0
            animPos = 0;
            animDir = 1;
        end
        switch animTarget
            case 'fs'
                sld.Value = round(animPos*1000)/1000;
                updateDisplay();
            case 'T'
                Tnew = Teut + round(animPos*(700 - Teut)/0.5)*0.5;
                tempDisplay = Tnew;
                tempSld.Value = Tnew;
                updateDisplay();
            case 'k'
                kField.Value = min(logMax,max(logMin,logVal(animPos)));
                updateDisplay();
            case 'c0'
                c0Field.Value = min(logMax,max(logMin,logVal(animPos)));
                updateDisplay();
        end
    end

    function onClose()
        stopAnim();
        if ~isempty(animTimer) && isvalid(animTimer)
            delete(animTimer);
        end
        delete(fig);
    end

    function updatePanelLayout()
        if isLimitedLiquid()
            pg.Visible = 'on';
            pg.RowHeight = {30,30,0,0,0,0,0,0};
            ctrl.RowHeight = {32,22,42,34,26,20,42,30,30,30,30,88,28,60,34};
            set([vLbl vField dlLbl dlField],'Visible','on');
            set([dsLbl dsField tfLbl tfField lamLbl lamField ...
                 aCLbl aCField wtCheck betaCheck betaField],'Visible','off');
        elseif isCK()
            pg.Visible = 'on';
            pg.RowHeight = {0,0,30,30,30,30,26,30};
            ctrl.RowHeight = {32,22,42,34,26,20,42,30,30,30,30,204,28,60,34};
            set([vLbl vField dlLbl dlField],'Visible','off');
            set([dsLbl dsField tfLbl tfField lamLbl lamField ...
                 aCLbl aCField wtCheck betaCheck betaField],'Visible','on');
        else
            pg.Visible = 'off';
            ctrl.RowHeight = {32,22,42,34,26,20,42,30,30,30,30,0,28,60,34};
        end
    end

    % ── Temperature-concentration coupling ─────────────────
    % Quadratic liquidus and solidus fits through the Al-Cu points
    % (0, 660.3), (4.8, 648), (33, 548) and
    % (0, 660.3), (0.8304, 648), (5.65, 548).
    function r = quadRoot(a,b,cFit,T)
        if T >= cFit
            r = 0;
            return;
        end
        disc = b^2 - 4*a*(cFit - T);
        if disc < 0
            r = 0;
        else
            r = (-b - sqrt(disc))/(2*a);
        end
    end

    function c = liquidusC(T)
        c = max(0, quadRoot(-0.0298060391,-2.41943101,660.3,T));
    end

    function c = solidusC(T)
        c = max(0, quadRoot(-1.05070285,-13.93963508,660.3,T));
    end

    function kk = kAtT(T)
        cl = liquidusC(T);
        cs = solidusC(T);
        if cl < 1e-8
            kk = kRef;
        else
            kk = cs/cl;
        end
    end

    function d = dsAtT(T)
        d = dsRef*exp(-(Qs/Rgas)*(1/(T+273.15) - 1/(Tref+273.15)));
    end

    function d = dlAtT(T)
        d = dlRef*exp(-(Ql/Rgas)*(1/(T+273.15) - 1/(Tref+273.15)));
    end

    function syncTemperature(Tnow)
        if tempLinkCheck.Value
            kField.Value  = kAtT(Tnow);
            dlField.Value = dlAtT(Tnow)*1e9;
            dsField.Value = dsAtT(Tnow)*1e12;
            dlField.Enable = 'off';
            dsField.Enable = 'off';
        else
            dlField.Enable = 'on';
            dsField.Enable = 'on';
        end
        % k stays editable: typing or dragging its slider is a manual override.
        kField.Enable = 'on';
        kField.Tooltip = 'Type a value or move the k slider to override temperature coupling';
        valT.Text = sprintf('T = %.1f C',Tnow);
        tieLbl.Text = tieLineText(Tnow);
    end

    function s = propText(kk)
        s = sprintf('k = %.4f   D_s = %.3g   D_L = %.3g m^2/s', ...
            kk,dsField.Value*1e-12,dlField.Value*1e-9);
    end

    function s = tieLineText(Tnow)
        if Tnow >= Tm
            s = sprintf('T = %.1f C: fully liquid (T > T_m = %.1f C)',Tnow,Tm);
        else
            s = sprintf('T = %.1f C  ->  C_L = %.2f, C_S = %.3f wt.%%  (k = %.4f)', ...
                Tnow,liquidusC(Tnow),solidusC(Tnow),kAtT(Tnow));
        end
    end

    % ── Limited liquid diffusion ───────────────────────────
    function d = deltaNow()
        v = max(vField.Value*1e-6, 1e-12);
        dl = max(dlField.Value*1e-9, 1e-15);
        d = dl/(v*L0);
    end

    % ── Clyne-Kurz ─────────────────────────────────────────
    function a = alphaBase()
        lam = max(lamField.Value*1e-6, 1e-12);
        a = 4*(dsField.Value*1e-12)*tfField.Value / (lam^2);
    end

    function a = alphaEff()
        a = alphaBase();
        if wtCheck.Value
            a = 2*(a + aCField.Value);
        end
    end

    function b = betaCK(a)
        if betaCheck.Value
            b = max(0,min(1,betaField.Value));
            return;
        end
        if ~(a > 0)
            b = 0;
        elseif isinf(a)
            b = 1;
        else
            b = 2*a*(1 - exp(-1/a)) - exp(-1/(2*a));
        end
    end

    function y = ckCLNorm(fsVal,kVal)
        y = zeros(size(fsVal));
        if abs(kVal - 1) < 1e-12
            y(:) = 1;
            return;
        end
        b = betaCK(alphaEff());
        q = b*kVal - 1;
        if abs(q) < 1e-10
            y = exp((1 - kVal)*fsVal);
        else
            y = (1 + q*fsVal).^((1 - kVal)/q);
        end
    end

    function a = ckAvgNorm(fsVal,kVal)
        cl = ckCLNorm(fsVal,kVal);
        a = zeros(size(fsVal));
        small = fsVal < 1e-9;
        a(small) = kVal;
        idx = ~small & fsVal < 1 - 1e-12;
        a(idx) = (1 - (1 - fsVal(idx)).*cl(idx))./fsVal(idx);
        a(fsVal >= 1 - 1e-12) = 1;
    end

    % ── Limited liquid diffusion ───────────────────────────
    function [x,S,I] = limitedProfile(kVal,deltaVal)
        key = sprintf('%.12g|%.12g',kVal,deltaVal);
        if strcmp(key,limitedKey)
            x = limitedX; S = limitedS; I = limitedI;
            return;
        end
        N = 1400;
        xmax = 0.9999;
        dx = xmax/N;
        x = (0:N)'*dx;
        S = zeros(N+1,1);
        I = zeros(N+1,1);
        S(1) = kVal;
        for ig = 2:N+1
            xx = x(ig);
            l = max(1 - xx, 1e-9);
            sPrev = S(ig-1);
            s = sPrev;
            for it = 1:8
                Ii = I(ig-1) + 0.5*(sPrev + s)*dx;
                deficit = xx - Ii;
                cStar = 1 + deficit/(deltaVal*(1 - exp(-l/deltaVal)));
                s = kVal*cStar;
            end
            S(ig) = s;
            I(ig) = I(ig-1) + 0.5*(sPrev + s)*dx;
        end
        limitedKey = key;
        limitedX = x;
        limitedS = S;
        limitedI = I;
    end

    function v = limitedSAt(fsVal,kVal,deltaVal)
        if fsVal >= 1 - 1e-12
            v = Inf;
            return;
        end
        [x,S,~] = limitedProfile(kVal,deltaVal);
        v = interp1(x,S,min(max(fsVal,0),x(end)));
    end

    function v = limitedAvgAt(fsVal,kVal,deltaVal)
        if fsVal < 1e-9
            v = kVal;
            return;
        elseif fsVal >= 1 - 1e-12
            v = 1;
            return;
        end
        [x,~,I] = limitedProfile(kVal,deltaVal);
        v = interp1(x,I,min(fsVal,x(end)))/fsVal;
    end

    function v = limitedCLAvgAt(fsVal,kVal,deltaVal)
        if fsVal >= 1 - 1e-12
            v = Inf;
            return;
        elseif fsVal < 1e-9
            v = 1;
            return;
        end
        [x,~,I] = limitedProfile(kVal,deltaVal);
        Ii = interp1(x,I,min(fsVal,x(end)));
        v = (1 - Ii)/(1 - fsVal);
    end

    % ── Axis limits ────────────────────────────────────────
    function top = yTopMain()
        kVal = kField.Value;
        if isLimitedLiquid()
            deltaVal = deltaNow();
            csCap = limitedSAt(0.99,kVal,deltaVal);
            clCap = csCap/kVal;
            top = min(25, 1.06*max([1 kVal csCap clCap]));
        elseif isCK()
            b = betaCK(alphaEff());
            if b < 1e-6
                if kVal < 1
                    top = min(25, 1.06*max(1,0.05^(kVal-1)));
                else
                    top = 1.06*max(1,kVal);
                end
            else
                clCap = ckCLNorm(0.999,kVal);
                top = min(25, 1.06*max([1 kVal clCap kVal*clCap ...
                    ckAvgNorm(0.999,kVal)]));
            end
        elseif isScheil()
            if kVal < 1
                top = min(25, 1.06*max(1,0.05^(kVal-1)));
            else
                top = 1.06*max(1,kVal);
            end
        else
            top = 1.06*max([1 kVal 1/kVal]);
        end
        if ~isfinite(top) || top <= 0
            top = 2;
        end
    end

    function top = yTopSpatial(csN,clN,avgN)
        vals = [1 kField.Value csN clN avgN];
        vals = vals(isfinite(vals));
        top = min(25, 1.12*max(vals));
        if ~isfinite(top) || top <= 0
            top = 2;
        end
    end

    function s = fmtNum(v)
        if isinf(v)
            s = char(8734);            % infinity symbol
        elseif isnan(v)
            s = char(8212);            % em dash
        else
            s = sprintf('%.3f',v);
        end
    end

    function updateDisplay(fsRequested)
        if nargin < 1 || isempty(fsRequested)
            fsRequested = sld.Value;
        end

        Tnow = tempDisplay;
        syncTemperature(Tnow);
        syncParamSliders();

        kNow  = kField.Value;
        c0Now = c0Field.Value;
        fsNow = max(0,min(1,fsRequested));

        % ── Current compositions, normalized to C0 ──
        if isLimitedLiquid()
            csN = limitedSAt(fsNow,kNow,deltaNow());
            clN = csN/kNow;
            avgN = limitedAvgAt(fsNow,kNow,deltaNow());
            clAvgN = limitedCLAvgAt(fsNow,kNow,deltaNow());
        elseif isCK()
            clN = ckCLNorm(fsNow,kNow);
            csN = kNow*clN;
            avgN = ckAvgNorm(fsNow,kNow);
            clAvgN = clN;
        elseif isScheil()
            clN = (1 - fsNow)^(kNow - 1);
            csN = kNow*clN;
            if fsNow < 1e-9
                avgN = kNow;
            else
                avgN = (1 - (1 - fsNow)^kNow)/fsNow;
            end
            clAvgN = clN;
        else
            den = 1 - (1 - kNow)*fsNow;
            csN = kNow/den;
            clN = 1/den;
            avgN = csN;
            clAvgN = clN;
        end

        csNow = csN*c0Now;
        clNow = clN*c0Now;
        avgNow = avgN*c0Now;
        clAvgNow = clAvgN*c0Now;

        singular = fsNow >= 1 - 1e-9 && ...
            ((isScheil() && kNow < 1) || isLimitedLiquid() || ...
             (isCK() && betaCK(alphaEff()) < 1e-9 && kNow < 1));

        % ── Main curves ──
        if isLimitedLiquid()
            [tx,tS,~] = limitedProfile(kNow,deltaNow());
            csCurve = interp1(tx,tS,fsGrid);
            clCurve = csCurve/kNow;
        elseif isCK()
            clCurve = ckCLNorm(fsGrid,kNow);
            csCurve = kNow*clCurve;
        elseif isScheil()
            base = (1 - fsGrid).^(kNow - 1);
            clCurve = base;
            csCurve = kNow*base;
        else
            den = 1 - (1 - kNow)*fsGrid;
            csCurve = kNow./den;
            clCurve = 1./den;
        end
        csCurve(~isfinite(csCurve)) = NaN;
        clCurve(~isfinite(clCurve)) = NaN;
        set(hCS,'YData',csCurve);
        set(hCL,'YData',clCurve);

        yTop = yTopMain();
        csPt = csN;
        clPt = clN;
        if ~isfinite(csPt), csPt = NaN; end
        if ~isfinite(clPt), clPt = NaN; end
        set(hPtS,'XData',fsNow,'YData',csPt);
        set(hPtL,'XData',fsNow,'YData',clPt);
        set(hGuide,'XData',[fsNow fsNow],'YData',[0 yTop]);
        ylim(ax,[0 yTop]);

        % ── Stage bands ──
        if isLimitedLiquid()
            delta = deltaNow();
            xInit = min(0.45, delta/kNow);
            xFinal = max(0.55, 1 - delta);
            if xFinal <= xInit
                xFinal = min(1, xInit + 1e-3);
            end
            edges = [0 xInit xFinal 1];
            for jb = 1:3
                xe = edges(jb); xf = edges(jb+1);
                set(hBand(jb),'XData',[xe xf xf xe], ...
                    'YData',[0 0 yTop yTop],'Visible','on');
                set(hBandText(jb),'Position',[(xe+xf)/2 0.94*yTop], ...
                    'Visible','on');
            end
        else
            for jb = 1:3
                set(hBand(jb),'Visible','off');
                set(hBandText(jb),'Visible','off');
            end
        end

        % ── Spatial profile ──
        yTopS = yTopSpatial(csN,clN,avgN);
        if isFixedView()
            yTopS = yTopMain();
        end
        set(hRegionS,'XData',[0 fsNow fsNow 0], ...
            'YData',[0 0 yTopS yTopS]);
        set(hRegionL,'XData',[fsNow 1 1 fsNow], ...
            'YData',[0 0 yTopS yTopS]);

        if fsNow < 1e-9
            xSolid = [0 0];
            ySolid = [NaN NaN];
        elseif isLimitedLiquid()
            [tx,tS,~] = limitedProfile(kNow,deltaNow());
            xSolid = linspace(0,fsNow,220);
            ySolid = interp1(tx,tS,xSolid);
        elseif isCK()
            xSolid = [0 fsNow];
            ySolid = [avgN avgN];
        elseif isScheil()
            xSolid = linspace(0,fsNow,220);
            ySolid = kNow*(1 - xSolid).^(kNow - 1);
        else
            xSolid = [0 fsNow];
            ySolid = [csN csN];
        end
        ySolid(~isfinite(ySolid)) = NaN;
        set(hSpatialS,'XData',xSolid,'YData',ySolid);

        % Liquid profile
        if fsNow < 1 - 1e-9 && isfinite(clN)
            if isLimitedLiquid()
                z = linspace(0,1-fsNow,140);
                yLiquid = 1 + (clN - 1)*exp(-z/deltaNow());
                xLiquid = fsNow + z;
                yLiquid(~isfinite(yLiquid)) = NaN;
                set(hSpatialL,'XData',xLiquid,'YData',yLiquid, ...
                    'LineStyle','-','DisplayName','Liquid, C_L(z)');
            else
                set(hSpatialL,'XData',[fsNow 1],'YData',[clN clN], ...
                    'LineStyle','--','DisplayName','Liquid, C_L');
            end
            set(hSpatialPtL,'XData',fsNow,'YData',clN,'Visible','on');
        else
            set(hSpatialL,'XData',NaN,'YData',NaN);
            set(hSpatialPtL,'XData',NaN,'YData',NaN,'Visible','off');
        end

        set(hSpatialPtS,'XData',fsNow,'YData',csPt);
        set(hSpatialGuide,'XData',[fsNow fsNow],'YData',[0 yTopS]);

        % Solid-liquid connector at the interface: green then orange.
        if isfinite(csPt) && isfinite(clPt)
            yMid = (csPt + clPt)/2;
            set(hConnS,'XData',[fsNow fsNow],'YData',[csPt yMid]);
            set(hConnL,'XData',[fsNow fsNow],'YData',[yMid clPt]);
        else
            set(hConnS,'XData',NaN,'YData',NaN);
            set(hConnL,'XData',NaN,'YData',NaN);
        end

        % Boundary-layer thickness marker
        if isLimitedLiquid() && fsNow < 1 - 1e-9
            delta = deltaNow();
            zEnd = min(delta, 1 - fsNow);
            if zEnd > 0.004
                yD = 0.07*yTopS;
                set(hDelta,'XData',[fsNow fsNow+zEnd], ...
                    'YData',[yD yD],'Visible','on');
                set(hDeltaTick1,'XData',[fsNow fsNow], ...
                    'YData',[yD-0.02*yTopS yD+0.02*yTopS],'Visible','on');
                set(hDeltaTick2,'XData',[fsNow+zEnd fsNow+zEnd], ...
                    'YData',[yD-0.02*yTopS yD+0.02*yTopS],'Visible','on');
                if zEnd < delta
                    lbl = 'delta/L';
                else
                    lbl = sprintf('delta/L = %.3f',delta);
                end
                set(hDeltaText,'Position',[fsNow+zEnd/2 yD+0.05*yTopS], ...
                    'String',lbl,'Visible','on');
            else
                set([hDelta hDeltaTick1 hDeltaTick2 hDeltaText],'Visible','off');
            end
        else
            set([hDelta hDeltaTick1 hDeltaTick2 hDeltaText],'Visible','off');
        end

        % Clyne-Kurz: link the back-diffused average to the interface value
        if isCK() && isfinite(csPt) && isfinite(avgN) && ...
                abs(csN - avgN) > 0.01
            set(hAvgLink,'XData',[fsNow fsNow],'YData',[avgN csN], ...
                'Visible','on');
        else
            set(hAvgLink,'Visible','off');
        end

        ylim(axSpatial,[0 yTopS]);

        % ── Labels, equations, readout ──
        if isLimitedLiquid()
            head.Text = 'SOLUTE REDISTRIBUTION  |  LIMITED LIQUID DIFFUSION';
            eq.Text = {'C_S(x) = C_0[k + (1-k)(1 - e^{-k x/(\delta/L)})]', ...
                       'C_L(z) = C_0[1 + (1-k)/k e^{-z/(\delta/L)}]', ...
                       '\delta/L = D_L/(vL),  L = 1 mm'};
            note.Text = ['No solid diffusion (D_S = 0), no liquid mixing. ' ...
                'Initial transient -> steady C_S = C_0 -> final transient.'];
            hCS.DisplayName = 'Solid (interface), C_S';
            title(axSpatial,sprintf('Along bar: solid profile and liquid boundary layer | %.1f%% solid', ...
                100*fsNow));
            if fsNow >= 1 - 1e-9
                balanceText = 'Mass balance: liquid singular at f_s = 1';
            else
                bals = fsNow*avgN + (1-fsNow)*clAvgN;
                balanceText = sprintf('Mass balance: %.6f wt.%%  (C_0 = %.3f)', ...
                    bals*c0Now, c0Now);
            end
            readout.Value = {
                'Model   No solid diffusion, limited liquid diffusion'
                tieLineText(Tnow)
                propText(kNow)
                sprintf('Solid (interface)  C_S* = %s wt.%%',fmtNum(csNow))
                sprintf('Average solid      C_S,avg = %s wt.%%',fmtNum(avgNow))
                sprintf('Liquid (interface) C_L* = %s wt.%%',fmtNum(clNow))
                sprintf('Average liquid     C_L,avg = %s wt.%%',fmtNum(clAvgNow))
                sprintf('Boundary layer     delta/L = %.4f',deltaNow())
                balanceText
                };
        elseif isCK()
            aB = alphaBase();
            aE = alphaEff();
            bCK = betaCK(aE);
            head.Text = 'SOLUTE REDISTRIBUTION  |  CLYNE-KURZ';
            eq.Text = {'C_L/C_0 = [1 - (1-\beta k) f_s]^{(k-1)/(1-\beta k)}', ...
                       '\beta = 2\alpha(1 - e^{-1/\alpha}) - e^{-1/(2\alpha)}', ...
                       '\alpha = 4 D_s t_f / \lambda_2^2'};
            if betaCheck.Value
                note.Text = sprintf(['Finite back diffusion; mixed liquid. ' ...
                    'beta = %.4g (direct override; alpha and Won-Thomas bypassed).'], ...
                    bCK);
            elseif wtCheck.Value
                note.Text = sprintf(['Finite back diffusion; mixed liquid. ' ...
                    'alpha = %.4g, alpha+ = %.4g, beta = %.4g (Won-Thomas).'], ...
                    aB, aE, bCK);
            else
                note.Text = sprintf(['Finite back diffusion; mixed liquid. ' ...
                    'alpha = %.4g, beta = %.4g.'],aB,bCK);
            end
            hCS.DisplayName = 'Solid (interface), C_S';
            title(axSpatial,sprintf('Along bar: back-diffused average solid | %.1f%% solid', ...
                100*fsNow));
            if singular
                balanceText = 'Mass balance: liquid singular at f_s = 1';
            else
                bals = fsNow*avgN + (1-fsNow)*clAvgN;
                balanceText = sprintf('Mass balance: %.6f wt.%%  (C_0 = %.3f)', ...
                    bals*c0Now, c0Now);
            end
            if betaCheck.Value
                betaLine = sprintf('beta = %.5g (direct override)',bCK);
            else
                betaLine = sprintf('alpha = %.5g   beta = %.5g',aE,bCK);
            end
            readout.Value = {
                'Model   Clyne-Kurz (finite back diffusion, mixed liquid)'
                tieLineText(Tnow)
                propText(kNow)
                sprintf('Solid (interface)  C_S* = %s wt.%%',fmtNum(csNow))
                sprintf('Average solid      C_S,avg = %s wt.%%',fmtNum(avgNow))
                sprintf('Liquid             C_L = %s wt.%%',fmtNum(clNow))
                betaLine
                balanceText
                };
        elseif isScheil()
            head.Text = 'SOLUTE REDISTRIBUTION  |  SCHEIL-GULLIVER';
            eq.Text = {'C_S = k C_0 (1 - f_s)^{k-1}', ...
                       'C_L =     C_0 (1 - f_s)^{k-1}'};
            note.Text = ['No solid diffusion (D_S = 0), perfectly mixed ' ...
                'liquid (D_L -> inf), local equilibrium k = C_S/C_L.'];
            hCS.DisplayName = 'Solid (interface), C_S';
            title(axSpatial,sprintf('Along bar: cored solid | %.1f%% solid', ...
                100*fsNow));
            if singular
                balanceText = 'Mass balance: singular at f_s = 1 (C_L -> inf)';
            else
                bals = fsNow*avgN + (1-fsNow)*clAvgN;
                balanceText = sprintf('Mass balance: %.6f wt.%%  (C_0 = %.3f)', ...
                    bals*c0Now, c0Now);
            end
            readout.Value = {
                'Model   Scheil-Gulliver (D_S = 0, D_L -> inf)'
                tieLineText(Tnow)
                propText(kNow)
                sprintf('Solid (interface)  C_S* = %s wt.%%',fmtNum(csNow))
                sprintf('Average solid      C_S,avg = %s wt.%%',fmtNum(avgNow))
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
            bals = fsNow*avgN + (1-fsNow)*clAvgN;
            balanceText = sprintf('Mass balance: %.6f wt.%%  (C_0 = %.3f)', ...
                bals*c0Now, c0Now);
            readout.Value = {
                'Model   Equilibrium (lever rule)'
                tieLineText(Tnow)
                propText(kNow)
                sprintf('Solid   C_S = %s wt.%%',fmtNum(csNow))
                sprintf('Liquid  C_L = %s wt.%%',fmtNum(clNow))
                balanceText
                };
        end

        valFs.Text = sprintf('f_s = %.3f',fsNow);
        title(ax,sprintf('Composition at f_s = %.3f',fsNow));
        drawnow limitrate;
    end
end
