clear all
close all

%windows
files = dir('F:\DJP_wave_clus\dec13*\times_*.mat'); % file = dir('times_*.mat');
%linux
% files = dir('/media/dan/MICROCENTER/DJP_wave_clus/dec13_171213_134218/times_*_2.mat'); % file = dir('times_*.mat');

% For each channel
for j=1:length(files)
    curr_file = fullfile(files(j).folder, files(j).name)
    load(curr_file);
    
    num_classes = max(cluster_class(:,1))
    load(fullfile(files(j).folder, 'adc_data.mat')); % adc_dat is the variable
        
    %% For each class of cells
    % we ignore class 0, the garbage spikes
    % cluster_class is in ms!
    handle=figure; % this will be the easel on which we paint our poorly spelled masterpiece.
    for i = 1:num_classes 
        I = find(cluster_class(:,1) == i); % all indices of cluster class i
        sp_t = cluster_class(I,2);
        
        diff_data = diff([0,adc_dat,0]);
        jump_start  = find(diff_data > 1);
        jump_end = find(diff_data < -1);
        
        % raster and histo parameters
        window = 1000; % 1 s or 1000 ms
        bin = 16; % make 5 ms bins
        histo_data = zeros(window/bin,1);
        
        %% For each stim time, put in raster
        spike_times=cell(length(jump_start),1);
        for j = 1:length(jump_start)
            
            % Putting data in raster
            curr = 1 / 30000 * 1000 * jump_start(j); % converting from samples to ms
            spike_times{j} = 1 / 1000 * (intersect(...
                sp_t(sp_t > (curr - window / 2))',...
                sp_t(sp_t < (curr + window / 2))') - curr); % centers, converts ms to seconds
            
            %% Histogram
            % Binning data for histogram around the stim in milliseconds
%             for k = 1:(window/bin) % indices in ms
%                 % k starts at 0, steps by size bin, converted to s,
%                 % centered around 0 by subtracting by 0.5 s
%                 spike_bin = ((k-1) * bin) - (window / 2); 
%                 histo_data(k) = histo_data(k) + numel(intersect(...
%                     spike_times{j}(spike_times{j} * 1000 > spike_bin),... % multiplying by 1000 converts to ms
%                     spike_times{j}(spike_times{j} * 1000 < spike_bin + bin))); 
%             end
        end
        
        % If there are multiple spike classes, we plot them together to see
        % how their latencies compare
        raster_axes=subplot(2*num_classes, 2, 2*i-1);
        if i == 1
            title_axes=raster_axes;
        end
        [xpoints, ~]=plotSpikeRaster(spike_times, 'PlotTYpe','vertline');
        
        histo_axes = subplot(2*num_classes, 2, 2*i);
        % TODO: I have made subplot(~,1,~) subplot(~,2,~), allowing a space
        % next to the graphs in which I intend to display the waveform, as
        % well as the width and summetry of the waveform, displayed in a
        % text box, I think. This info will be extractable from the fig,
        % I'm pretty sure.
        % We want to make this so that the waveofrm is edited in the
        % subplot, so you see "is this good?" and the findchangepts next to
        % the histogram.
        
        bin_ms = 20; % bin size in ms
        histogram(histo_axes, xpoints, (-window/ (2 * 1000)):bin_ms/1000:(window/(2 * 1000)));%bar(histo_data); %histogram(histo_data, window/bin); % consider using a bar graph
        
        
        %% Waveform analysis
        % put this is another script
%         [width,ratio]=DJP_waveform(spikes,I);
        
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