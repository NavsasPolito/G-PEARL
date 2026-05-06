function [msg] = genReport_2(reportPath, reportTitle, templatePath, textFields, figures, outputConsole, oprtComment)

msg = "";

%% --- Import libraries
try
    makeDOMCompilable();
    import mlreportgen.report.*
    import mlreportgen.dom.*
catch ME
    msg = "Library import failing";
    warning(msg);
    disp(getReport(ME));
    return;
end

%% --- Ensure output folder exists
try
    if ~exist(reportPath, 'dir')
        mkdir(reportPath);
    end
catch ME
    msg = "Cannot create output directory";
    warning(msg);
    disp(getReport(ME));
    return;
end

%% --- Resolve template path (CRITICAL for Runtime)
try
    if isdeployed
        templatePathResolved = templatePath;
    else
        templatePathResolved = templatePath;
    end

    if ~exist(templatePathResolved, 'file')
        error("Template not found: %s", templatePathResolved);
    end
catch ME
    msg = "Template resolution failed";
    warning(msg);
    disp(getReport(ME));
    return;
end

%% --- Create document
try
    outputFile = fullfile(reportPath, reportTitle);
    D = Document(outputFile, 'docx', templatePathResolved);
catch ME
    msg = "File creation failed";
    warning(msg);
    disp(getReport(ME));
    return;
end

%% --- Open document
try
    open(D);
catch ME
    msg = "File opening failed";
    warning(msg);
    disp(getReport(ME));
    D
    return;
end

%% --- Fill report
try
    % --- Text fields
    for textIdx = 1:numel(textFields)
        moveToNextHole(D);
        T = Text(textFields(textIdx));
        T.WhiteSpace = "pre-wrap";
        append(D, T);
    end
    moveToNextHole(D);

    % --- Figures
    for iFig = 1:numel(figures)

        try
            w = sscanf(figures(iFig).Width,'%dpx');
            h = sscanf(figures(iFig).Height,'%dpx');

            if isempty(w) || isempty(h) || h == 0
                warning("Invalid figure size, skipping resize");
            else
                r = w / h;
                h_r = 6.7 / r;
                rS = max(h_r / 9, 1);

                height = sprintf("%.3fin", h_r / rS);
                width  = sprintf("%.3fin", 6.7 / rS);

                figures(iFig).Width  = width;
                figures(iFig).Height = height;
            end

            append(D, figures(iFig));
            moveToNextHole(D);

        catch MEfig
            warning("Figure insertion failed");
            disp(getReport(MEfig));
        end
    end

    % --- Console output
    if nargin >= 6 && ~isempty(outputConsole)
        T = Text(strjoin(string(outputConsole), newline));
        T.WhiteSpace = "pre-wrap";
        append(D, T);
        moveToNextHole(D);
    end

    % --- Operator comments
    if nargin >= 7 && ~isempty(oprtComment)
        T = Text(strjoin(string(oprtComment), newline));
        T.WhiteSpace = "pre-wrap";
        append(D, T);
    end

catch ME
    msg = "Report assembly failed";
    warning(msg);
    disp(getReport(ME));
end

%% --- Close document
try
    close(D);

    % Avoid forcing PDF in Runtime (can fail)
    if ~isdeployed
        rptview(D.OutputPath);
    else
        rptview(D.OutputPath);
        disp("Report generated at:");
        disp(D.OutputPath);
    end

catch ME
    msg = "Report closure failed";
    warning(msg);
    disp(getReport(ME));
end

end