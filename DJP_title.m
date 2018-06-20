function [ title ] = DJP_title( input )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
title_str = strsplit(input, '\'); % 1 x n cell
title_str = title_str(end); % take nth cell
title_str = title_str{1}; % take the contents of cell of cell (wtf, matlab)
title_str = title_str(1:end-4); % removes '.wav'
title = strrep(title_str, '_', ' ');
end