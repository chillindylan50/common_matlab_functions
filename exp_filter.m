function [ filtered ] = exp_filter(in_data, exponential_constant )
% exp_filter apply exponential filter to data
%   [ filtered ] = exp_filter( in_data, exponential_constant ) applies an exponential
%   filter to all data in in_data matrix row by row, using constant exponential_constant
%   TODO: 
%   1. (High Priority) replace with matlab's "filter" function

    % Initialize array
    filtered = zeros(size(in_data));
    filtered(1,:) = in_data(1,:);
    
    % Apply exponential filter to all columns of data
    for ii = 2:size(in_data,1) %All rows
        filtered(ii,:) = filtered(ii-1,:)*exponential_constant + (1-exponential_constant)*in_data(ii,:);
    end
end

