function [width, ratio ] = DJP_waveform( spikes, I )
%DJP_WAVEFORM_ANALYSIS Summary of this function goes here
%   Detailed explanation goes here

        figure; plot(mean(spikes(I,:)))
        figure; plot(spikes(I,:)')
        %% This allows for human supervision, when the parameter encapsulates the spike
        % add a CLI element to check and then confirm parameter
        sp_mean = mean(spikes(I,:));
        confirm = 'n';
        parameter = '4';
        figure;
        while ~(confirm == 'y')
            close all;
            
            findchangepts(sp_mean,'Statistic','Linear',...
                'MaxNumChanges', str2num(parameter))
            message = strcat('Does this look right? (do the onset and offset of ',...
            'the peak align with the outer vertical lines?) [y/n]\n');
            confirm = input(message, 's');
            
            if ~(confirm == 'y')
                parameter = input(strcat(...
                    'Select new parameter (current parameter =',...
                    num2str(parameter),')\n'), 's');
            end
        end
        %% Proceed with data analysis
        width=DJP_p2p(sp_mean, str2double(parameter));
        ratio= 'I decided to remove symmetry as a dimension, since symmetry only
        can tell us about where on the neuron we were recording. Do we care 
        about that?' %DJP_sym(sp_mean, str2double(parameter));

end