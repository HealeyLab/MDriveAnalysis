clear all
close all

path = uigetdir('.','Select directory with wave_clus-sorted units');
files = dir(fullfile(path, 'times_*.mat')); % file = dir('times_*.mat');
% Gets stim info
stim_text_file = dir(fullfile(path, '*markers.txt'));
fid = fopen(fullfile(stim_text_file.folder, stim_text_file.name));
stim_order = textscan(fid, '%s', 'Delimiter', '\n');
fclose(fid);

stim_order = stim_order{1};
stim_classes = unique(stim_order);

for j=1:length(files)
% For each channel
    curr_file = fullfile(files(j).folder, files(j).name)
    load(curr_file);
    
    num_classes = max(cluster_class(:,1))
    load(fullfile(files(j).folder, 'adc_data.mat')); % adc_dat is the variable
     
    %% For each stimulus class
    for m = 1:length(stim_order)
        
        % For each class of cells
        for i = 1:num_classes
            % we ignore class 0, the garbage spikes
            % cluster_class is in ms!
            I = find(cluster_class(:,1) == i); % all indices of cluster class i
            sp_t = cluster_class(I,2);
            diff_data = diff(adc_dat);
            jump_start  = find(diff_data > 1);
            
            % Only for the stimulus class we want:
            stim_indices = ismember(stim_order, stim_classes{m});
            jump_start = jump_start(stim_indices);
            
            % raster and histo parameters
            window = 2000; % 1 s or 1000 ms
            left = window * .1;
            right = window * .9;
            
            
            %% For each stim time, put in raster
            spike_times=cell(length(jump_start),1);
            for k = 1:length(jump_start)
                % Putting data in raster, window is in ms
                % Note: adc_sr is a variable saved with adc_data
                curr = 1 / adc_sr * 1000 * jump_start(k); % converting from samples to ms
                % next two lines: 100 ms before, 3900 ms after threshold cross. more
                % like 3500 ms after stim onset.
                spike_times{k} = 1 / 1000 * (intersect(...
                    sp_t(sp_t > (curr - left))',...
                    sp_t(sp_t < (curr + right))') - curr); % centers, converts ms to seconds
                
                
            end
            % TODO: I have made subplot(~,1,~) subplot(~,2,~), allowing a space
            % next to the graphs in which I intend to display the waveform, as
            % well as the width and summetry of the waveform, displayed in a
            % text box, I think. This info will be extractable from the fig,
            % I'm pretty sure. We want to make this so that the waveofrm is edited in the
            % subplot, so you see "is this good?" and the findchangepts next to
            % the histogram. If there are multiple spike classes, we plot them together to see
            % how their latencies compare
            handle=figure; % this will be the easel on which we paint our poorly spelled masterpiece.
            height = 2;
            width = num_classes;
            
            raster_axes=subplot(height, width, i);
            if i == 1
                title_axes=raster_axes;
            end
            
            [xpoints, ~]=plotSpikeRaster(spike_times, 'PlotTYpe','vertline');
            
            histo_axes = subplot(height, width, i+num_classes);
            bin_ms = 20; % bin size in ms
            histogram(histo_axes, xpoints, (-left/1000):bin_ms/1000:(right/1000));
            ax=gca;
            set(ax, 'XLim', [-left/1000 right/1000]);
            
            %% Waveform analysis
            % put this is another script
            %         [width,ratio]=DJP_waveform(spikes,I);
        end
    end
    %% format & save graph
    fig_file_name=strcat(...
        files(j).name(1:end-4),...
        '_class', num2str(i),...
        '.fig');
    fig_file_name=strrep(fig_file_name, '_', ' '); % b/c of something weird with title function

    title(title_axes, fig_file_name)
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