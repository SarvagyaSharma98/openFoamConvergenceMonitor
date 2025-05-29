% =========================================================================
% OpenFOAM Log File Real-Time Residual & Courant Number Monitor
% -------------------------------------------------------------------------
% Monitors a live OpenFOAM solver log (e.g., reactingFoam) and plots:
%   - Initial and Final Residuals for specified fields
%   - Maximum Temperature
%   - Mean and Max Courant Numbers
%
% Author: Sarvagya Sharma (https://github.com/SarvagyaSharma98)
% Contributor: Sarvagya Sharma, IISc Blr.
%
% HOW TO USE:
% 1. Set the 'logFile' variable below to your OpenFOAM log file path.
%    - Supports Windows, Linux, or WSL-style paths.
% 2. (Optional) Adjust 'fields' for the solver variables you want to track.
% 3. Run this script in MATLAB (R2020b or newer recommended).
% 4. Press Ctrl+C in MATLAB to stop the monitoring at any time.
%
% REQUIREMENTS:
%   - MATLAB R2020b or newer (for tiledlayout plotting)
%   - OpenFOAM log file (e.g., reactingFoam, rhoReactingFoam)
%
% =========================================================================

clear; clc;

% ----------------------- User Configuration ------------------------------
logFile = fullfile(pwd, 'log.reactingFoam'); % <-- Change this to your log file path

PlotSteps = 500;           % Number of recent time steps to display in plot
ResetInterval = 10;        % Main loop cycles before full reset (10*20s = 200s)
fields = {'Ux', 'Uy', 'T', 'p', 'OH', 'CO', 'h'}; % Fields to monitor

% ------------------ End of User Configuration ----------------------------

numFields = numel(fields);

disp('OpenFOAM Log Monitor: Press Ctrl+C in MATLAB to stop.');

while true % Reset outer loop

    [resData, courant, maxT, seenTimes, fig, cycleCount] = initializeData(fields);

    while true % Main monitoring loop
        cycleCount = cycleCount + 1;
        logTxt = tryReadFile(logFile);
        if isempty(logTxt), pause(5); continue; end

        % --- Extract all available time steps ---
        [times, positions, tokens] = extractTimes(logTxt);
        if isempty(times), disp('No time steps found. Waiting...'); pause(10); continue; end

        % --- Process new time steps ---
        [resData, courant, maxT, seenTimes] = ...
            processTimeSteps(times, positions, tokens, logTxt, seenTimes, resData, fields, courant, maxT);

        % --- Select most recent times for plotting ---
        lastTimes = selectRecentTimes(times, PlotSteps);

        % --- Plot results ---
        fig = plotDiagnostics(fig, fields, resData, lastTimes, maxT, courant, tokens);

        % --- Pause and check for reset ---
        drawnow;
        pause(20);
        if cycleCount >= ResetInterval
            close(fig); clc;
            disp('========== RESETTING MONITOR (timed restart) ==========');
            break; % Restart everything to avoid memory leaks
        end
    end
end

%% ====================== Helper Functions Below ========================

function [resData, courant, maxT, seenTimes, fig, cycleCount] = initializeData(fields)
    % Initializes storage for field residuals, Courant numbers, etc.
    numFields = numel(fields);
    for k = 1:numFields
        resData.(fields{k}) = containers.Map('KeyType','double','ValueType','any');
    end
    courant.mean = containers.Map('KeyType','double','ValueType','double');
    courant.max  = containers.Map('KeyType','double','ValueType','double');
    maxT.val     = containers.Map('KeyType','double','ValueType','double');
    seenTimes = [];
    fig = [];
    cycleCount = 0;
end

function logTxt = tryReadFile(logFile)
    % Tries to read the log file, handling errors gracefully
    if ~isfile(logFile)
        disp(['Log file not found: ' logFile]);
        logTxt = '';
        return;
    end
    try
        logTxt = fileread(logFile);
    catch ME
        disp(['Error reading file: ' ME.message]);
        logTxt = '';
    end
end

function [times, positions, tokens] = extractTimes(logTxt)
    % Finds all time steps in the log file
    timeExpr = 'Time = ([\d\.eE+-]+)';
    [tokens, positions] = regexp(logTxt, timeExpr, 'tokens', 'start');
    if isempty(tokens), times = []; return; end
    times = cellfun(@(x) str2double(x{1}), tokens);
end

function [resData, courant, maxT, seenTimes] = ...
    processTimeSteps(times, positions, tokens, logTxt, seenTimes, resData, fields, courant, maxT)
    numFields = numel(fields);
    for idx = 1:numel(times)
        t = times(idx);
        if ismember(t, seenTimes), continue; end
        startIdx = positions(idx);
        if idx < numel(times)
            endIdx = positions(idx+1) - 1;
        else
            endIdx = length(logTxt);
        end
        stepTxt = logTxt(startIdx:endIdx);

        % --- Field Residuals ---
        for f = 1:numFields
            field = fields{f};
            pat = [field, ', Initial residual = ([\d\.eE+-]+), Final residual = ([\d\.eE+-]+)'];
            hit = regexp(stepTxt, pat, 'tokens', 'once');
            if ~isempty(hit)
                resData.(field)(t) = [str2double(hit{1}), str2double(hit{2})];
            end
        end

        % --- Courant Numbers ---
        courantPat = 'Courant Number mean: ([\d\.eE+-]+) max: ([\d\.eE+-]+)';
        cHits = regexp(stepTxt, courantPat, 'tokens');
        if ~isempty(cHits)
            hit = cHits{end};
            courant.mean(t) = str2double(hit{1});
            courant.max(t)  = str2double(hit{2});
        end

        % --- Max Temperature ---
        TmaxPat = 'min/max\(T\) = [\d\.eE+-]+, ([\d\.eE+-]+)';
        TmaxHit = regexp(stepTxt, TmaxPat, 'tokens', 'once');
        if ~isempty(TmaxHit)
            maxT.val(t) = str2double(TmaxHit{1});
        end

        % Mark as processed
        seenTimes(end+1) = t;
    end
end

function lastTimes = selectRecentTimes(times, PlotSteps)
    % Selects the most recent N time steps for plotting
    if numel(times) < PlotSteps
        lastTimes = times;
    else
        lastTimes = times(end-PlotSteps+1:end);
    end
end

function fig = plotDiagnostics(fig, fields, resData, lastTimes, maxT, courant, tokens)
    % Plots all diagnostics in a single, clear figure
    numFields = numel(fields);
    if isempty(fig) || ~isvalid(fig)
        fig = figure('Name','OpenFOAM Convergence Monitor');
        set(fig, 'WindowState', 'maximized');
    end
    figure(fig); clf;
    set(fig, 'WindowState', 'maximized');
    tl = tiledlayout(2,5,"TileSpacing","compact","Padding","compact");

    % --- Field Residuals ---
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
        iRes(iRes==0) = 1e-16; fRes(fRes==0) = 1e-16; % Prevent log(0)
        semilogy(lastTimes, iRes, '-ob', lastTimes, fRes, '-sr', 'LineWidth',1.3,'MarkerSize',7);
        xlabel('Time'); ylabel('Residual');
        legend('Initial','Final','Location','best');
        title(['Residuals: ', field]);
        grid on; set(gca, 'FontSize', 11); axis tight;
    end

    % --- Max Temperature ---
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

    % --- Courant mean ---
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

    % --- Courant max ---
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

    % --- Overall Title ---
    try
        latestTimeStr = tokens{end}{1};
        title(tl, sprintf('Convergence Monitor (latest Time = %s)', latestTimeStr), ...
            'FontWeight', 'bold', 'FontSize', 15);
    catch
        title(tl, 'Convergence Monitor', 'FontWeight', 'bold', 'FontSize', 15);
    end
end
