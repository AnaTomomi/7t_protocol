%% Automated datalist creation!
% This script reads in files in the raw
% Nifti dir and generates a Gratton-Lab friendly datalist. 
% Keep in mind that you should make QC filtered copies with problematic
% sessions or runs removed. 
%% JC, 52/28/25
%%
%%%% PARAMS %%%%


TR = 1.18; % Repetition Time in seconds (1.18 for CUPS, 1.945 for SMS)
dropFR = 5; % Number of frames to drop
topDir = '/projects/illinois/las/psych/cgratton/networks-pm/7t/pilot_bids_cups/derivatives';
dataFolder = 'fmriprep-24.1.1';
confoundsFolder = 'fmriprep-24.1.1';
FDtype = 'fFD';
outdir = sprintf('%s/datalists/beforeqc', topDir); % Output dir

%%%%%%

% Create output directory if it doesn't exist
if ~exist(outdir, 'dir')
    mkdir(outdir);
end

% Define the base directory for subject data
base_dir = fullfile(topDir);

% Get list of subject directories
parent_dir = fileparts(base_dir);
sub_dirs = dir(fullfile(parent_dir, 'sub-*'));

for i = 1:length(sub_dirs)
    sub_name = sub_dirs(i).name;
    
    % Ensure subject name is formatted as PM2XXXX
    if startsWith(sub_name, 'sub-')
        formatted_sub_name = extractAfter(sub_name, 'sub-'); % Remove 'sub-' prefix
    else
        warning('Skipping subject: %s (incorrect format)', sub_name);
        continue;
    end

    % Get list of sessions for each subject
    sess_dir = dir(fullfile(parent_dir, sub_name, 'ses-*'));
    sess_dir = sess_dir([sess_dir.isdir]);

    % Initialize datalist for the subject
    datalist = {};

    for s = 1:length(sess_dir)
        sess = extractAfter(sess_dir(s).name, 'ses-'); % Convert 'ses-1' to '1'

        % Search for functional runs
        func_dir = fullfile(parent_dir, sub_name, sess_dir(s).name, 'func');
        func_files = dir(fullfile(func_dir, [sub_name '_' sess_dir(s).name '_task-*_run-*_bold.nii.gz']));

        % Initialize containers for tasks and runs
        task_runs = containers.Map;

        for j = 1:length(func_files)
            file_name = func_files(j).name;

            % Extract task name
            task_match = regexp(file_name, 'task-(.*?)_', 'tokens');
            if ~isempty(task_match)
                task_name = task_match{1}{1};
            else
                task_name = 'unknown';
            end

            % Extract run number
            run_match = regexp(file_name, 'run-(\d+)_bold.nii.gz', 'tokens'); 
            if ~isempty(run_match)
                run_number = str2double(run_match{1}{1});
            else
                run_number = NaN;
            end

            % Add run number to the corresponding task
            if isKey(task_runs, task_name)
                task_runs(task_name) = [task_runs(task_name), run_number];
            else
                task_runs(task_name) = run_number;
            end
        end

        % Create datalist entry for each session
        tasks = keys(task_runs);
        for k = 1:length(tasks)
            task_name = tasks{k};
            run_numbers = sort(task_runs(task_name));
            run_str = sprintf('"%s"', strjoin(arrayfun(@num2str, run_numbers, 'UniformOutput', false), ',')); % Ensure runs are in double quotes

            % Add row with session information
            datalist{end+1, 1} = sprintf('%s,%s,%s,%.2f,%d,%s,%s,%s,%s,%s', ...
                formatted_sub_name, sess, task_name, TR, dropFR, topDir, dataFolder, confoundsFolder, FDtype, run_str);
        end
    end

    % Save datalist as a .txt file in the specified output directory
    txt_filename = fullfile(outdir, [formatted_sub_name '_datalist_fmriprep-24.1.1.txt']);
    fileID = fopen(txt_filename, 'w');

    % Write header line (CSV format)
    fprintf(fileID, 'sub,sess,task,TR,dropFr,topDir,dataFolder,confoundsFolder,FDtype,runs\n');

    % Write data rows
    fprintf(fileID, '%s\n', datalist{:});
    fclose(fileID);
    
    disp(['Saved datalist: ' txt_filename]);
end
