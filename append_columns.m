function expanded_array = append_columns(destination_array, dest_time_col, source_array, source_time_col, columns_to_add, varargin)
% append_column Append a column from a source array onto a destination array.
%  expanded_array = append_column(destination_array, dest_time_col, source_array, source_time_col, columns_to_add)
%  Appends columns_to_add from the source_array into the destination_array, such that the times in dest_time_col and source_time_col match.
%  If source has more rows, we will downsample it (skip some rows in source). 
%  If destination has more rows, we will put a given source row in multiple destination rows.
%
%  Example:
%  sensor_data_expanded = append_column(sensor_data, time_column_arduino, instron, time_column, displacement_column);


%% 1. Process inputs
p = inputParser;
addRequired(p, 'destination_array', @isnumeric) % The destination array
addRequired(p, 'dest_time_col', @isnumeric) % The time column in the destination array
addRequired(p, 'source_array', @isnumeric) % The source array
addRequired(p, 'source_time_col', @isnumeric) % The time column in the source array
addRequired(p, 'columns_to_add', @isnumeric) % Which columns of the source array to add to the destination array
addParameter(p, 'scale_factor', 1000, @isnumeric) % Scale factor for the source time. Typically Instron has time (s) while Arduino data has time (ms).
parse(p, destination_array, dest_time_col, source_array, source_time_col, columns_to_add, varargin{:})


%% 2. Loop over data, and append data from source onto the destination array
% 2.1 Initialize expanded array and timekeeping variables
num_rows = size(destination_array, 1);
num_columns_initial = size(destination_array, 2);
num_columns_add = size(columns_to_add, 2);
expanded_array = [destination_array, zeros(num_rows, num_columns_add)];

num_rows_source = size(source_array, 1);
current_row_source = 1;
next_row_source = 2;
next_time_source = source_array(next_row_source, source_time_col);


% 2.2 Are there more rows in the source array?
source_more_rows = false;
if(num_rows_source > num_rows)
    source_more_rows = true;
end

% 2.3 Loop over the data and append data from souce onto the right side of destination array, row by row
if(source_more_rows) % Downsample the source. I.e., we will only keep the row in source that was collected just after a row in the destination.
    for row = 1:num_rows
        current_time = destination_array(row, dest_time_col) / p.Results.scale_factor;
            
        % Skip over the rows in source until we have exceeded the current row in destination
        while (current_time > next_time_source)
            % Only increment "next row" if there's another row available
            if current_row_source >= num_rows_source
%                 num_valid_rows = row;
                break
            end
            current_row_source = current_row_source + 1;
            next_time_source = source_array(current_row_source, source_time_col);
        end

        expanded_array(row, num_columns_initial + 1:num_columns_initial + num_columns_add) = source_array(current_row_source, columns_to_add);
    end
else % Upsample, i.e. add the same source row to multiple destination rows
    for row = 1:num_rows 
        current_time = destination_array(row, dest_time_col) / p.Results.scale_factor; % Always increment the destination time
        
        % If we crossed the "next time in the source array", we can use the next row of source data!
        if (current_time >= next_time_source)
            current_row_source = next_row_source;
            
            % Increment "next row" if there's another row available
            if current_row_source < num_rows_source
                next_row_source = current_row_source + 1;
                next_time_source = source_array(next_row_source, source_time_col);
            end
        end

        expanded_array(row, num_columns_initial + 1:num_columns_initial + num_columns_add) = source_array(current_row_source, columns_to_add);
    end
end

% expanded_array(num_valid_rows:end, :) = [];

