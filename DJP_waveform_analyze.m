% Author: DJP 6/17/18
%% Note
% In order to allow this script to connect waveform to spiking properties,
% the local master file will have the entries indexed in such a way that if
% you loop through each file and through each class (excluding garbage),
% you can reconstruct which index in the local master file corresponds to
% each entry into the master matrix, and therefore which spiking profile
% corresponds to which.
close all;
clear all;

% Get working directory
% Lower branches will have smaller master files (summaries of waveform
% information) than higher branches, which will incorporate the lower
% master files into themselves...at some point. I'm not sure when. For now,
% just make the functionality to create a master file in a particular
% directory.    

% *_spikes.mat files contain spikes, an n by 64 double matrix

% a = dir(fullfile(pwd, '*_spikes.mat'))
%   16�1 struct array with fields:
%     name, folder, date, bytes, isdir

% basic mode input, may want to hardcode later
use_cur_dir = input('Use current directory or choose somewhere else? (y/n)', 's'); 
if lower(use_cur_dir) == 'y'
    direc = pwd;
elseif lower(use_cur_dir) == 'n'
    direc = uigetdir;
end
% Check master exists
master_exists = ~isempty(dir(fullfile(direc, 'spike_master.mat')));
master_path = fullfile(direc, 'spike_master.mat');
if master_exists
    load(master_path)
else
    % NaN(p2p, firingrate, [include, exclude, unsure])
    % Note: each file will (can) have multiple rows, since they can have
    % multiple units
    summary = NaN(3,1); % ones(rows,columns) or ones(height, width)
end

    
% ***************************
% for each channel, make cell

times_files = dir(fullfile(direc, 'times_*.mat'));
data_cell = cell(0);
for i = 1:size(times_files, 1)

    disp([times_files(i).name])
    
    % load current data, both *_spikes.mat file and times_*.mat file
    times_file = fullfile(times_files(i).folder, times_files(i).name);
    load(times_file, 'cluster_class', 'spikes');
    load(raw_data_file, 'data','sr')
    % normal .mat raw data file:
    % data                  1xnumel(data points)
    % sr                    srlen
    
    % *_spikes.mat:
    %   index               1x7142                57136  double
    %   par                 1x1                    3886  struct
    %   psegment            1x100000             800000  double
    %   spikes           7142x64                3656704  double
    %   sr_psegment         1x1                       8  double
    %   threshold           1x2                      16  double
    
    % times_*.mat:
    %   Temp                  1x5                    40  double
    %   cluster_class      7142x2                114272  double
    %   forced                1x7142               7142  logical
    %   inspk              7142x10               571360  double
    %   ipermut               1x7142              57136  double
    %   par                   1x1                  8490  struct
    %   spikes             7142x64              3656704  double
    
    
    % Looping through classes IN EACH FILE
    num_classes = max(cluster_class(:,1)); % this excludes the garbage class, 0
    for j = 1:num_classes
        data_cell{end+1} = [times_file ' ' num2str(j) ' ' numel(data)/sr]; % take apart later
        clear(data, sr)
    end
end

% **********************************************
% for each channel (cell), populate the database
for cell_ind = 1:length(data_cell) % we ignore class 0, the garbage spikes
    % Now load the data for current, unpack data_cell
    split_data = strsplit(data_cell{cell_ind}); % whitespace default delimiter, unpacks into new cell
    load(split_data{1}, 'cluster_class', 'spikes');
    % Get current cluster & plot
    class_ind = split_data{2};
    I = find(cluster_class(:,1) == str2double(class_ind)); % all indices of cluster class i
    
    FR = numel(I)/split_data{3}; % in Hz
    
    avg_spk = mean(spikes(I, :));
    plot(avg_spk)
    
    % First time, acceptablein will not exist, so that's the first logical
    userin = 'start'; % userin just can't be empty or it's always wrong
    while any([all([userin ~= 'c' userin ~= 'i' userin ~= 'e' userin ~= 'u']) userin == 'start'])
        % if we categorize it (include, exclude, unsure), or if we cancel,
        % we are done with this iteration of for loop
        userin = lower(input(...
        'back (B/b), include (I/i), exclude (E/e), unsure (U/u),view trace (T/t), cancel(C/c), view current progress (V/v)\n', 's'));
        
        switch userin
            case 'b'
                % go back: decrement by 2, loop will incrememnt it to
                % previous element
                cell_ind = cell_ind - 2;
                
            case {'i', 'e', 'u'}
                % include: add it to our local master matrix with 1 as
                % third variable, indicates include
                
                % exclude: add it to our local master matrix with 2 as
                % third variable, indicates exclude
                
                % unsure: add it to our local master matrix with 3 as
                % third variable, indicates unsure
                if userin == 'e'
                    [p2p, FR] = deal(NaN); % like deal NaN cards to each variable
                    code = 2; % I know this numbering is unintuitive. Sorry. See below for clarification.
                else
                    [p2p, FR] = DJP_waveform(spikes, I);
                    if userin == 'i'
                        code = 1;
                    else
                        code = 3;
                    end
                end
                
                % adding data to database
                if cell_ind == (length(summary) + 1)                                         %          [1        2        3     ]
                    summary = [summary; [p2p FR code]]; % [p2p FR [include, exclude, unsure]]
                elseif cell_ind <= length(summary)
                    summary(:, cell_ind) = [p2p FR code];
                else
                    throw(ME)
                end
                
            case 't'
                % trace: view trace (again)
                plot(avg_spike)
                
            case 'c'
                % cancel: Create/append master file and close down
                if master_exists % must make current matfile
                    save('spike_master.mat', summary);
                else % there is a master file, must append to it using matfile
                    m = matfile(master_path, 'Writable', true);
                    m.summary = summary;
                end
                % cancel command also breaks out for loop
                
            case 'v'
                % view progress: see what the summary matrix looks like
                disp(summary)
            
            otherwise
                disp(['Command not recognized. Try again']);
        
        end % end of switch
    end % end of while
    
    if userin == 'c'
        % part of cancelling. Not very atomic, sue me.
        break;
    end
end % end of for


    