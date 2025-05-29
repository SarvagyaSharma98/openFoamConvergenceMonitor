% =========================================================================
% Real-Time OpenFOAM Residual & Courant Number Monitor
% Author: Sarvagya Sharma
% Date: May 2025
% OpenFOAM Version: v2412
%
% This MATLAB script reads a live OpenFOAM log file (e.g., from reactingFoam)
% and plots:
%   - Initial and Final Residuals of selected fields
%   - Maximum Temperature
%   - Mean and Max Courant Numbers
% in real time, refreshing periodically.
%
% HOW TO USE:
% 1. Set the full path to your OpenFOAM log file in the logFile variable.
% 2. Set PlotSteps to control how many latest time steps to display.
% 3. Run the script. It will keep monitoring and updating every ~20 seconds.
% 4. Press Ctrl+C in MATLAB to stop the live plotting.
%
% REQUIREMENTS:
% - MATLAB R2020b or later (recommended for tiledlayout support).
% - Log file from a PIMPLE-based OpenFOAM solver like reactingFoam.
%
% FIELDS MONITORED:
% You can customize the monitored fields by editing the fields cell array.
%
% NOTE:
% - This script is tailored for OpenFOAM v2412 log format, not guaranteed to work
%   with heavily customized solver outputs.
% - Make sure MATLAB has read permissions for the log file.
%
% Share & modify freely with attribution.
% =========================================================================

clear; clc;

% -------------------------------------------------------------------------
% User Configuration
% -------------------------------------------------------------------------
logFile = '\\wsl.localhost\Ubuntu-22.04\home\sarvagya\OpenFOAM\sarvagya-11\run\mckenna\log.reactingFoam'; 
% Path to OpenFOAM log file (edit this)

PlotSteps = 250;  % Number of most recent time steps to display in the plot

fields = {'Ux', 'Uy', 'T', 'p', 'OH', 'CO', 'h'};  % Fields to track residuals for
numFields = numel(fields);

% Initialize data containers for each field and diagnostic
for k = 1:numFields
    resData.(fields{k}) = containers.Map('KeyType','double','ValueType','any');  % Map: time -> [initial, final residual]
end
courant.mean = containers.Map('KeyType','double','ValueType','double');
courant.max  = containers.Map('KeyType','double','ValueType','double');
maxT.val     = containers.Map('KeyType','double','ValueType','double');
seenTimes = [];  % Tracks already-processed time steps

fig = [];  % Will hold the figure object
disp('Monitoring log file... Press Ctrl+C to stop.');

% -------------------------------------------------------------------------
% Main Loop - Continuously monitor and plot
% -------------------------------------------------------------------------
while true
    % --- Try reading the log file ---
    if ~isfile(logFile)
        disp('Log file not found, waiting...');
        pause(5);
        continue;
    end
    try
        logTxt = fileread(logFile);
    catch
        disp('Error reading file. Retrying...');
        pause(5);
        continue;
    end

    % --- Extract time steps from log file ---
    timeExpr = 'Time = ([\d\.eE+-]+)';
    [tokens, positions] = regexp(logTxt, timeExpr, 'tokens', 'start');
    if isempty(tokens)
        disp('No time steps found. Waiting...');
        pause(10);
        continue;
    end
    times = cellfun(@(x) str2double(x{1}), tokens);

    % --- Extract data for each new time step ---
    for idx = 1:numel(times)
        t = times(idx);
        if ismember(t, seenTimes)
            continue;  % Skip if already processed
        end
        startIdx = positions(idx);
        if idx < numel(times)
            endIdx = positions(idx+1) - 1;
        else
            endIdx = length(logTxt);
        end
        stepTxt = logTxt(startIdx:endIdx);

        % --- Extract residuals for each field ---
        for f = 1:numFields
            field = fields{f};
            pat = [field, ', Initial residual = ([\d\.eE+-]+), Final residual = ([\d\.eE+-]+)'];
            hit = regexp(stepTxt, pat, 'tokens', 'once');
            if ~isempty(hit)
                resData.(field)(t) = [str2double(hit{1}), str2double(hit{2})];
            end
        end

        % --- Extract Courant numbers ---
        courantPat = 'Courant Number mean: ([\d\.eE+-]+) max: ([\d\.eE+-]+)';
        cHits = regexp(stepTxt, courantPat, 'tokens');
        if ~isempty(cHits)
            hit = cHits{end};
            courant.mean(t) = str2double(hit{1});
            courant.max(t)  = str2double(hit{2});
        end

        % --- Extract max temperature ---
        TmaxPat = 'min/max\(T\) = [\d\.eE+-]+, ([\d\.eE+-]+)';
        TmaxHit = regexp(stepTxt, TmaxPat, 'tokens', 'once');
        if ~isempty(TmaxHit)
            maxT.val(t) = str2double(TmaxHit{1});
        end

        % --- Mark time as processed ---
        seenTimes(end+1) = t;
    end

    % --- Define the subset of recent time steps to plot ---
    if numel(times) < PlotSteps
        lastTimes = times;
    else
        lastTimes = times(end-PlotSteps+1:end);
    end

    % ---------------------------------------------------------------------
    % Plotting Section
    % ---------------------------------------------------------------------
    if isempty(fig) || ~isvalid(fig)
        fig = figure('Name','OpenFOAM Residuals & Courant/MaxT');
        set(fig, 'WindowState', 'maximized');  % Open full screen
    end
    figure(fig); clf;
    set(fig, 'WindowState', 'maximized');
    tl = tiledlayout(2,5,"TileSpacing","compact","Padding","compact");

    % --- Plot residuals for each field ---
    for f = 1:numFields
        nexttile(f)
        field = fields{f};
        iRes = nan(1,numel(lastTimes));
        fRes = nan(1,numel(lastTimes));
        for n = 1:numel(lastTimes)
            t = lastTimes(n);
            if resData.(field).isKey(t)
                vals = resData.(field)(t);
                iRes(n) = vals(1); fRes(n) = vals(2);
            end
        end
        iRes(iRes==0) = 1e-16; fRes(fRes==0) = 1e-16;  % Avoid log(0)
        semilogy(lastTimes, iRes, '-ob', lastTimes, fRes, '-sr', ...
            'LineWidth',1.3,'MarkerSize',7);
        xlabel('Time'); ylabel('Residual');
        legend('Initial','Final','Location','best');
        title(['Residuals: ', field]);
        grid on; set(gca, 'FontSize', 11); axis tight;
    end

    % --- Max temperature plot ---
    nexttile(8);
    mt = nan(1,numel(lastTimes));
    for n = 1:numel(lastTimes)
        t = lastTimes(n);
        if maxT.val.isKey(t), mt(n) = maxT.val(t); end
    end
    plot(lastTimes, mt, '-om', 'LineWidth', 1.3, 'MarkerSize',7);
    xlabel('Time'); ylabel('Max T [K]');
    title('Max Temperature');
    grid on; axis tight; set(gca, 'FontSize', 11);

    % --- Courant mean plot ---
    nexttile(9);
    coMean = nan(1,numel(lastTimes));
    for n = 1:numel(lastTimes)
        t = lastTimes(n);
        if courant.mean.isKey(t), coMean(n) = courant.mean(t); end
    end
    plot(lastTimes, coMean, '-ok', 'LineWidth', 1.3, 'MarkerSize',7);
    xlabel('Time'); ylabel('Mean Co');
    title('Mean Courant Number');
    grid on; axis tight; set(gca, 'FontSize', 11);

    % --- Courant max plot ---
    nexttile(10);
    coMax = nan(1,numel(lastTimes));
    for n = 1:numel(lastTimes)
        t = lastTimes(n);
        if courant.max.isKey(t), coMax(n) = courant.max(t); end
    end
    plot(lastTimes, coMax, '-sg', 'LineWidth', 1.3, 'MarkerSize',7);
    xlabel('Time'); ylabel('Max Co');
    title('Max Courant Number');
    grid on; axis tight; set(gca, 'FontSize', 11);

    % --- Title for the entire figure with latest time step ---
    latestTimeStr = tokens{end}{1};
    title(tl, sprintf('OpenFOAM Residuals, Courant & Max T (latest Time = %s)', latestTimeStr), ...
                'FontWeight', 'bold', 'FontSize', 15);

    % --- Refresh the plot every 20 seconds ---
    drawnow;
    pause(20);
end
