files = dir('./*.mat');
fid1 = fopen('files.txt', 'wt');
fid2 = fopen('files_spikes.txt', 'wt');
for i = 1:length(files)
    filename = files(i).name;
    fprintf(fid1, strcat(filename, '\n'));
    
    fn_parts = split(filename, '.');
    filename_spikes = strcat(fn_parts(1), '_spikes.', fn_parts(2));
    fprintf(fid2, strcat(filename_spikes, '\n'));
end
fclose(fid1);
fclose(fid2);