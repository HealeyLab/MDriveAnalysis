clear all
close all

path = uigetdir('.','Select directory with wave_clus-sorted units');

% something tricky here, load a data file with path name to get the sr
pathsplit=strsplit(path, filesep);
sr_cell = fullfile(path, strcat(pathsplit(end), '_1.mat'));
load(sr_cell{1}, 'sr');
time_files = dir(fullfile(path, 'times_*.mat')); % file = dir('times_*.mat');
shape_files = dir(fullfile(path, '*_spikes.mat'));
% Gets stim info
stim_text_file = dir(fullfile(path, '*markers.txt'));
fid = fopen(fullfile(stim_text_file.folder, stim_text_file.name));
stim_order = textscan(fid, '%s', 'Delimiter', '\n');
fclose(fid);

stim_order = stim_order{1};
stim_classes = unique(stim_order);

clear sr_cell pathsplit stim_text_file fid

% File == Channel
for file_ind=1:length(time_files)
    % For each channel
    curr_time_file = fullfile(time_files(file_ind).folder, time_files(file_ind).name);
    load(curr_time_file);
    
    % Load spike shapes, too
    curr_shape_file = fullfile(shape_files(file_ind).folder, shape_files(file_ind).name);
    load(curr_shape_file, 'spikes');

    num_classes = max(cluster_class(:,1));
    load(fullfile(time_files(file_ind).folder, 'adc_data.mat')); % adc_dat is the variable

    %% Making the figure
    fig_title = DJP_title(time_files(file_ind).name);
    handle=figure('units','normalized',...
        'outerposition',[0.25 0.25 1 1],...
        'Name', fig_title);
    title(fig_title)
    
    height = 1+2*num_classes;
    width = numel(stim_classes);
    %% For each stimulus class
    for stimulus_class_ind = 1:length(stim_classes)
        % For each class of cells
        for class_ind = 1:num_classes
            % we ignore class 0, the garbage spikes
            % cluster_class is in ms!
            I = find(cluster_class(:,1) == class_ind); % all indices of cluster class i
            sp_t = cluster_class(I,2); % is in milliseconds
            diff_data = diff(board_adc_data(2,:)); % so this is just stim times
            jump_start  = find(diff_data > 1);
            jump_end  = find(diff_data < -1);

            % Only for the stimulus class we want:
            stim_indices = ismember(stim_order, stim_classes{stimulus_class_ind});
            jump_start = jump_start(stim_indices);
            jump_end = jump_end(stim_indices); % just for the plotting step

            %% For each stim time, put in raster
            spike_times=cell(length(jump_start),1);
            for stimulus_ind = 1:length(jump_start)
                % Putting data in raster, window is in ms
                % Note: adc_sr is a variable saved with adc_data
                curr_start = 1 / adc_sr * jump_start(stimulus_ind) * 1000 - 2000; % converts to milliseconds
                curr_end = 1 / adc_sr * jump_end(stimulus_ind) * 1000 + 2000; % converts to milliseconds
                % sp_t is in fact in milliseconds
                left = 200;
                right = 1200;
                spike_times{stimulus_ind} = (intersect(...
                    sp_t(sp_t > curr_start'),... % sp_t(sp_t > (curr - left))',...
                    sp_t(sp_t < curr_end)')...
                    - curr_start); % centers

                spike_times{stimulus_ind} = 1 / 1000 * spike_times{stimulus_ind}'; % converts ms to seconds
            end
            %% Populating graph, first getting simulus
            if class_ind == 1
                stim_axes = subplot(height, width,...
                    stimulus_class_ind);
                
                title_str = DJP_title(stim_classes{stimulus_class_ind});
                title(stim_axes, title_str)
                hold on;
                
                stim_start = jump_start(1) - 2 * adc_sr;
                stim_end = jump_end(1) + 2 * adc_sr;
                plot(board_adc_data(1, stim_start:stim_end)) % take first stimulus of that kind
                xlim([stim_start stim_end])
                set(stim_axes, 'XLim', [0 (stim_end-stim_start)],...
                    'XTickLabel', [], 'xtick', [],...
                    'YTickLabel', [], 'ytick', [])
            end
            
            %raster
            % add num_classes to put it down a row
            raster_axes=subplot(height, width,...
                (2 * class_ind - 1) * width + stimulus_class_ind);
            
            [xpoints, ~] = plotSpikeRaster(spike_times,...
                'PlotTYpe','vertline', 'XLimForCell', [0 (curr_end(1)-curr_start(1))/1000]);%,...
            
            %histogram
            % add 2xnum_classes to put down two rows
            histo_axes = subplot(height, width,...
                2 * class_ind * width + stimulus_class_ind);
            
            % histo is in seconds
            bin = 0.020; % bin size in s
            histogram(histo_axes, xpoints, (0:bin:(curr_end(1)-curr_start(1))/1000)); % convert ms to s
            xlim([0, (curr_end(1)-curr_start(1))/1000])
            
            % Waveform analysis
            %[width,ratio]=DJP_waveform(spikes,I);

        end
    end
    %% format & save graph
    fig_file_name=strcat(...
        time_files(file_ind).name(1:end-4),...
        '.fig');
    fig_file_name=strrep(fig_file_name, '_', ' '); % b/c of something weird with title function
%     title(fig_file_name)
    savefig(handle, fullfile(time_files(file_ind).folder, fig_file_name), 'compact')

    close % should close most recent figure
end
