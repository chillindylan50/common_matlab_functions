function [ data_above_minimum ] = above_value( in_data, x_data_column, minimum_x_value, columns_to_zero, varargin )
% above_value remove all data that is below a minimum value.
%   [ data_above_minimum ] = above_value( in_data, x_data_column, minimum_x_value, varargin). Zero-out all data that is below a minimum value
%
%   Required inputs:
%   in_data = array with the input data.
%   x_data_column = column to be examined for being greater than a minimum
%   minimum_x_value = minimum acceptable x value (typically 0)
%
%   Optional inputs (positional):
%   N/A
%
%   Optional Parameters (not positional, specified by an identifying string):
%   truncateWithNaNs = Replace zero rows with NaN, to keep output array same dimensions as input arry.

% Function parser described here https://www.mathworks.com/help/matlab/matlab_prog/parse-function-inputs.html
% In brief: add[type](inputParser,name,check function)
p = inputParser;
addRequired(p, 'in_data')
addRequired(p, 'x_data_column', @isnumeric)
addRequired(p, 'minimum_x_value', @isnumeric)
addRequired(p, 'columns_to_zero', @isnumeric)
addParameter(p, 'truncateWithNaNs', false, @islogical)

parse(p, in_data, x_data_column, minimum_x_value, columns_to_zero, varargin{:})


if iscell(in_data)
    number_of_cells = size(in_data,1); % Number of cells
    data_above_minimum = cell(size(in_data));
    % Remove zero-rows from each cell individually
    for i = 1:number_of_cells
        temp_data = in_data{i}; 
        number_of_valid_rows = 1;

        % Re-add the data where the x value was above our minimum value.
        for row = 1: size(temp_data,1)
            if temp_data(row, x_data_column) > minimum_x_value
                temp_data(number_of_valid_rows, :) = temp_data(row, :);
                number_of_valid_rows = number_of_valid_rows + 1;
            end
        end

        if p.Results.truncateWithNaNs
            temp_data(temp_data == 0) = nan;
        end
        temp_data(~any(temp_data,2), :) = [];  % delete zero rows. Optional
        temp_data(:, p.Results.columns_to_zero) = temp_data(:, p.Results.columns_to_zero) - temp_data(1, p.Results.columns_to_zero); % Zero the force and displacement
        data_above_minimum{i} = temp_data;
    end
        % data_above_minimum( ~any(data_above_minimum,2), : ) = [];  % delete zero rows. Optional


elseif isnumeric(in_data)
    number_of_valid_rows = 1;
    data_above_minimum = zeros(size(in_data));

    % Re-add the data where the x value was above our minimum value.
    for row = 1: size(in_data,1)
        if in_data(row, x_data_column) > minimum_x_value
            data_above_minimum(number_of_valid_rows, :) = in_data(row, :);
            number_of_valid_rows = number_of_valid_rows + 1;
        end
    end

    if p.Results.truncateWithNaNs
        data_above_minimum(data_above_minimum == 0) = nan;
    end
    data_above_minimum( ~any(data_above_minimum,2), : ) = [];  % delete zero rows. Optional
    data_above_minimum(:, p.Results.columns_to_zero) = data_above_minimum(:, p.Results.columns_to_zero) - data_above_minimum(1, p.Results.columns_to_zero); % Zero the appropriate columns
else
    error("above_value expected numeric data, got non-numeric in_data.")
end
