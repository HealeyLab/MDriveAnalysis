clear all
close all

path = uigetdir('.','Select directory with wave_clus-sorted units');

% something tricky here, load a data file with path name to get the sr
pathsplit=strsplit(path, filesep);
sr_cell = fullfile(path, strcat(pathsplit(end), '_1.mat'));
load(sr_cell{1}, 'sr');
files = dir(fullfile(path, 'times_*.mat')); % file = dir('times_*.mat');

% Gets stim info
stim_text_file = dir(fullfile(path, '*markers.txt'));
fid = fopen(fullfile(stim_text_file.folder, stim_text_file.name));
stim_order = textscan(fid, '%s', 'Delimiter', '\n');
fclose(fid);

stim_order = stim_order{1};
stim_classes = unique(stim_order);

clear sr_cell pathsplit stim_text_file fid

% File == Channel
for file_ind=1:length(files)
    % For each channel
    curr_file = fullfile(files(file_ind).folder, files(file_ind).name)
    load(curr_file);

    num_classes = max(cluster_class(:,1))
    load(fullfile(files(file_ind).folder, 'adc_data.mat')); % adc_dat is the variable

    %% Making the figure
    handle=figure;
    height = 1+2*num_classes;
    width = numel(stim_classes);
    %% For each stimulus class
    for stimulus_class_ind = 1:length(stim_order)
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
                curr = 1 / adc_sr * jump_start(stimulus_ind) * 1000; % converts to milliseconds

                % sp_t is in fact in milliseconds
                left = 200;
                right = 1200;
                spike_times{stimulus_ind} = (intersect(...
                    sp_t(sp_t > (curr - left))',...
                    sp_t(sp_t < (curr + right))')...
                    - curr); % centers

                spike_times{stimulus_ind} = 1 / 1000 * spike_times{stimulus_ind}; % converts ms to seconds
            end
            %% Populating graph
            % add 0*num_classes, put it at top
            stim_axes = subplot(height, width, class_ind);
            title_str = strsplit(stim_classes{stimulus_class_ind}, filesep); % 1 x n cell
            title_str = title_str(end); % take nth cell
            title_str = title_str{1}; % take the contents of cell of cell (wtf, matlab)
            title_str = title_str(1:end-4); % removes '.wav'
            title(stim_axes, stim_classes{stimulus_class_ind})
            plot(board_adc_data(1, jump_start(1):jump_end(1))) % take first stimulus of that kind
            ax=gca;
            set(ax,'XLim', [jump_start(1) jump_end(1)])

            % add num_classes to put it down a row
            raster_axes=subplot(height, width, num_classes+class_ind);
            [xpoints, ~]=plotSpikeRaster(spike_times, 'PlotTYpe','vertline');

            % add 2xnum_classes to put down two rows
            histo_axes = subplot(height, width, 2*class_ind+num_classes);
            % histo is in seconds
            bin = 0.020; % bin size in s
            histogram(histo_axes, xpoints, (-left:bin:right)/1000); % convert ms to s
            ax=gca;
            set(ax, 'XLim', [-left right]/1000); % see last comment

            % Waveform analysis
            %[width,ratio]=DJP_waveform(spikes,I);

        end
    end
    %% format & save graph
    fig_file_name=strcat(...
        files(file_ind).name(1:end-4),...
        '_neuron_class_', num2str(class_ind),...
        'stimulus_class_', stim_classes{stim_index},...
        '.fig');
    fig_file_name=strrep(fig_file_name, '_', ' '); % b/c of something weird with title function
    title(fig_file_name)
    savefig(handle, fig_file_name, 'compact')

    close % should close most recent figure
end
            %% Histogram
%           bin = 16; % make 5 ms bins
%           histo_data = zeros(window/bin,1);
            % Binning data for histogram around the stim in milliseconds
%             for k = 1:(window/bin) % indices in ms
%                 % k starts at 0, steps by size bin, converted to s,
%                 % centered around 0 by subtracting by 0.5 s
%                 spike_bin = ((k-1) * bin) - (window / 2);
%                 histo_data(k) = histo_data(k) + numel(intersect(...
%                     spike_times{j}(spike_times{j} * 1000 > spike_bin),... % multiplying by 1000 converts to ms
%                     spike_times{j}(spike_times{j} * 1000 < spike_bin + bin)));
%             end
