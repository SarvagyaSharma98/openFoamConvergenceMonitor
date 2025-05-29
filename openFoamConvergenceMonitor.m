% =========================================================================
% OpenFOAM Convergence Real-Time Monitor App (with GUI)
% -------------------------------------------------------------------------
% This MATLAB app monitors an OpenFOAM solver log file (e.g., reactingFoam)
% and plots user selected quantities
%
% ***IMP NOTE***
% Developed for OpenFOAM v2412 log files that were generated during my trials of
% reactingFoam simulations with GRI 3.0 mechanism. not tested for other types of 
% simulations or log file formats.
%
% Features:
%   - Simple GUI: Select log file, fields to monitor, number of steps, reset interval
%   - Supports any fields present in your log (e.g., Ux, Uy, h, OH, CO, CO2, O2)
%   - Always plots max temperature and Courant numbers
%   - Plots update in real time; the monitor auto-restarts to avoid memory leaks
%
% HOW TO USE:
%   1. Run this script in MATLAB (R2020b or newer recommended).
%   2. Fill in the GUI fields and select your OpenFOAM log file.
%   3. Click "Start Monitoring" to launch the convergence plots.
%   4. To stop, close the monitoring figure or use Ctrl+C in the MATLAB command window.
%
% REQUIREMENTS:
%   - MATLAB R2020b or newer (uses uifigure, tiledlayout)
%   - OpenFOAM log file (from a parallel or serial run)
%   - File read permissions for the log file
%
% AUTHOR:
%   Sarvagya Sharma, IISc Bangalore
%   Code refined and made interactive with assistance from OpenAI's ChatGPT
%   Last updated: May 2025
%
% =========================================================================

function openfoam_residual_monitor_app
    % ------------------------- README END ------------------------------

    % Create Main App Window
    appFig = uifigure('Name','OpenFOAM Log Monitor Setup','Position',[100 100 440 380]);

    % --- Log File Path Input ---
    uilabel(appFig,'Position',[30 330 140 22],'Text','Log file path:');
    logEdit = uieditfield(appFig,'text','Position',[30 305 260 24],'Value',fullfile(pwd,'log.reactingFoam'));
    uibutton(appFig,'Position',[310 305 80 24],'Text','Browse...','ButtonPushedFcn',@(btn,evt)...
        browseLogFile(appFig,logEdit));

    % --- Fields Input ---
    uilabel(appFig,'Position',[30 265 320 22],'Text','Fields to monitor (comma-separated):');
    fieldEdit = uieditfield(appFig,'text','Position',[30 240 350 24],'Value','Ux, Uy, T, p, OH, CO, h');

    % --- Plot Steps Input ---
    uilabel(appFig,'Position',[30 205 260 22],'Text','PlotSteps (# of time steps to plot):');
    stepEdit = uieditfield(appFig,'numeric','Position',[240 205 60 24],'Value',500);

    % --- Reset Interval Input ---
    uilabel(appFig,'Position',[30 170 250 22],'Text','ResetInterval (number of cycles):');
    resetEdit = uieditfield(appFig,'numeric','Position',[240 170 60 24],'Value',50);

    % --- Info Text ---
    helpStr = ['After pressing Start, monitoring begins in a regular figure window.' newline ...
        'You can close this app window to reclaim space.' newline ...
        'Press Ctrl+C in MATLAB to stop the monitor at any time.'];
    uitextarea(appFig,'Value',helpStr,'Position',[30 80 360 60],'Editable','off','FontSize',12);

    % --- Start Monitoring Button (large and centered at bottom) ---
    uibutton(appFig,'Position',[120 30 200 36],'Text','Start Monitoring','FontWeight','bold', ...
        'FontSize',14,'ButtonPushedFcn', @(btn,evt)startMonitorCallback(...
            appFig, logEdit, fieldEdit, stepEdit, resetEdit));
end

%% ============ Button and UI Helper Functions ==============

function browseLogFile(appFig,logEdit)
    % Opens file browser and sets log file path in edit field
    [f,p] = uigetfile({'*','All Files'},'Select OpenFOAM Log File');
    if isequal(f,0), return; end
    logEdit.Value = fullfile(p,f);
end

function startMonitorCallback(appFig, logEdit, fieldEdit, stepEdit, resetEdit)
    % Collects all UI inputs and launches the monitoring logic
    logFile = logEdit.Value;
    fieldStr = fieldEdit.Value;
    fields = strtrim(strsplit(fieldStr,','));
    PlotSteps = stepEdit.Value;
    ResetInterval = resetEdit.Value;
    close(appFig); % Close the app window after collecting inputs

    % Call the monitor function in the background with user settings
    openfoam_residual_monitor_main(logFile, fields, PlotSteps, ResetInterval);
end

%% ========== Core Monitoring and Plotting Logic ===============

function openfoam_residual_monitor_main(logFile, fields, PlotSteps, ResetInterval)
    % Main real-time monitor loop; runs until user stops or window closes
    numFields = numel(fields);

    disp('OpenFOAM Log Monitor: Press Ctrl+C in MATLAB to stop.');

    while true % Outer loop for periodic reset (avoids memory leaks)
        [resData, courant, maxT, seenTimes, fig, cycleCount] = initializeData(fields);

        while true % Main monitoring loop
            cycleCount = cycleCount + 1;

            % --- Try to read log file (handles file busy/unavailable) ---
            logTxt = tryReadFile(logFile);
            if isempty(logTxt), pause(5); continue; end

            % --- Extract all available time steps ---
            [times, positions, tokens] = extractTimes(logTxt);
            if isempty(times), disp('No time steps found. Waiting...'); pause(10); continue; end

            % --- Process any new time steps for all tracked quantities ---
            [resData, courant, maxT, seenTimes] = ...
                processTimeSteps(times, positions, tokens, logTxt, seenTimes, resData, fields, courant, maxT);

            % --- Select only the N most recent time steps for plotting ---
            lastTimes = selectRecentTimes(times, PlotSteps);

            % --- Plot results (all in a maximized figure window) ---
            fig = plotDiagnostics(fig, fields, resData, lastTimes, maxT, courant, tokens);

            % --- Pause and check for reset ---
            drawnow;
            pause(20); % 20s between updates (adjust as needed)
            if cycleCount >= ResetInterval
                close(fig); clc;
                disp('========== RESETTING MONITOR (timed restart) ==========');
                break; % Restart everything to avoid memory leaks
            end
        end
    end
end

%% ====================== Helper Functions ============================

function [resData, courant, maxT, seenTimes, fig, cycleCount] = initializeData(fields)
    % Initializes containers for field residuals, Courant numbers, etc.
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
    % Attempts to read the log file, handles errors cleanly
    if ~isfile(logFile)
        disp(['Log file not found: ' logFile]);
        logTxt = '';
        return;
    end
    try
        fid = fopen(logFile, 'rt');
        if fid == -1
            logTxt = '';
            return;
        end
        logTxt = fread(fid, '*char')';
        fclose(fid);
    catch ME
        disp(['Error reading file: ' ME.message]);
        logTxt = '';
    end
end

function [times, positions, tokens] = extractTimes(logTxt)
    % Finds all "Time = <number>" in the log file
    timeExpr = 'Time = ([\d\.eE+-]+)';
    [tokens, positions] = regexp(logTxt, timeExpr, 'tokens', 'start');
    if isempty(tokens), times = []; return; end
    times = cellfun(@(x) str2double(x{1}), tokens);
end

function [resData, courant, maxT, seenTimes] = ...
    processTimeSteps(times, positions, tokens, logTxt, seenTimes, resData, fields, courant, maxT)
    % Processes each new time step and stores results for all requested fields
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

        % --- Field Residuals (Initial/Final) ---
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

        % Mark this time as processed
        seenTimes(end+1) = t;
    end
end

function lastTimes = selectRecentTimes(times, PlotSteps)
    % Returns only the most recent PlotSteps number of time steps
    if numel(times) < PlotSteps
        lastTimes = times;
    else
        lastTimes = times(end-PlotSteps+1:end);
    end
end

function fig = plotDiagnostics(fig, fields, resData, lastTimes, maxT, courant, tokens)
    % Plots all diagnostics in a maximized, organized figure window

    numFields = numel(fields);

    if isempty(fig) || ~isvalid(fig)
        fig = figure('Name','OpenFOAM Convergence Monitor');
        set(fig, 'WindowState', 'maximized');
    end
    clf(fig); % Clear figure content without bringing it to front
    set(fig, 'WindowState', 'maximized');
    tl = tiledlayout(2,5,"TileSpacing","compact","Padding","compact");

    % --- Residual Plots for each selected field ---
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
        iRes(iRes==0) = 1e-16; fRes(fRes==0) = 1e-16; % Avoid log(0)
        semilogy(lastTimes, iRes, '-ob', lastTimes, fRes, '-sr', 'LineWidth',1.3,'MarkerSize',7);
        xlabel('Time'); ylabel('Residual');
        legend('Initial','Final','Location','best');
        title(['Residuals: ', field]);
        grid on; set(gca, 'FontSize', 11); axis tight;
    end

    % --- Max Temperature Plot (always present, tile 8) ---
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

    % --- Courant Mean Plot (always present, tile 9) ---
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

    % --- Courant Max Plot (always present, tile 10) ---
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
