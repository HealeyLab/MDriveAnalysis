%% DO NOT RUN AS IS
% This is a brief set of clues to get you to where you need to be.
% 
% filename = concat_Intan_RHD2000_files;
% path = ?????;
% pathfile = fullfile(path, strcat(filename(1:end-4), 'filtered', '.mat'));
% par = set_parameters();
% xf_detect = spike_detection_filter(amplifier_data(??????,:), par);
% plot(xf_detect)
% save(filename, 'xf_detect', '-v7.3');

% lx = 1:60*30000;
% plot(xf_detect(lx), 'k');
% adc_data = double(board_adc_data(2,:) > 1);
% adc_data(adc_data == 0) = NaN;
% lower = adc_data < 1; % find returns indices
% lower = [lower(2:end) 0]; %shifting it over, adding opposite of higher to end so 
% higher = adc_data > 1; % find returns indices
% start = lower & higher;
% stop = ~(lower | higher);


X = reshape(find(diff([0,adc_dat,0])),2,[]);
X(2,:) = X(2,:)-1;
Y = [5;5];
plot(X,Y)