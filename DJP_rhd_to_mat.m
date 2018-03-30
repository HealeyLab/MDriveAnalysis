%% Author: DJP
% This should use the concat script to bring together all the intan files
% into one matrix. Then, they will be split up by channel and saved as
% their own files in a programmatically created folder.
close all;
clear all;
cd('\DJP_wave_clus\');

%% Concatenate rhd files and get filename
[foldername,path] = concat_Intan_RHD2000_files;
% channels x timepoints
if(iscell(foldername)) % when it's many files, it's number of files x 1
    foldername = foldername{1}(1:end-4);
else
    foldername = foldername(1:end-4);
end

numchan = size(amplifier_data, 1);

%% Create folder
mkdir(foldername)
cd(foldername)

%% Save files in this folder and text file , polytrodes.txt
for i = 1:numchan
    filename = strcat(foldername, '_', num2str(i));
    data = amplifier_data(i,:);
    save(filename, 'data', '-v7.3')
end
% Make the text files
DJP_make_files();
% Save stim data
adc_dat=board_adc_data(2,:);
save('adc_data', 'adc_dat', '-v7.3')
cd('..')
