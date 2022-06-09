function [ line ] = plot_clouds( cell_array_of_data, x_column, y_column, lower_bound_x, bin_width_x, upper_bound_x, varargin )
% DATAANALYSIS Plot clouds (confidence intervals.)
%   [ line ] = plot_clouds( cell_array_of_data, xCol, yCol, lower_bound_x, bin_width_x, upper_bound_x ) generates
%   information for the patches that can be plotted as clouds. Warning: will truncate negative response
%   (sensor, stress, etc.) confidence values to 0.01
%
%   Required Inputs:
%   cell_array_of_data = cell array with your data,
%   x_column, y_column = column number containing x,y data
%   lower_bound_x = Lower bound of your x data
%   bin_width_x = width of each bin
%   upper_bound_x = upper bound of your x data
%
%   Optional inputs:
%   clouds_first = plot clouds before plotting the mean. Default = TRUE
%   initial_row = first row that you want plotted. Deafult = 1
%   percent_to_right = what percent of the data lies to the right of your confidence interval's left bound. Ex.: 95% CI has percent_to_right = 0.975. Default = 0.975
%   plot_clouds = should we plot clouds around our data?
%   plot_raw = should we plot the raw data?
%   raw_number = how many samples' raw data should be plotted?
%   show_cloud_in_legend = should we show the cloud in the calling script's legend Default = FALSE.
%   specific_sd = should we use the confidence interval, or use a specific z-width?
%   specified_sd = how many SDs to use for the clouds
%   subtract_initial = should we subtract the initial value for a given column from all data in that column? Default = FALSE

%   Optional parameters:
%   
% 
%   Outputs:
%   line = the line corresponding to the mean of the data


%% 1. Parse Inputs
% Function parser described here https://www.mathworks.com/help/matlab/matlab_prog/parse-function-inputs.html
% In brief: add[type](inputParser,name,check function)
p = inputParser;
% Required (ordered) inputs
addRequired(p, 'cell_array_of_data', @iscell)
addRequired(p, 'x_column', @isnumeric)
addRequired(p, 'y_column', @isnumeric)
addRequired(p, 'lower_bound_x', @isnumeric)
addRequired(p, 'bin_width_x', @isnumeric)
addRequired(p, 'upper_bound_x', @isnumeric)
% Optional (ordered) inputs
addOptional(p, 'percent_to_right', 0.975, @isnumeric)
addOptional(p, 'initial_row', 1, @isnumeric)
addOptional(p, 'subtract_initial', true, @islogical)
addOptional(p, 'clouds_first', true, @islogical)
addOptional(p, 'show_cloud_in_legend', false, @islogical)
addOptional(p, 'plot_clouds', true, @islogical)
addOptional(p, 'plot_raw', false, @islogical)
addOptional(p, 'raw_number', 1, @isnumeric)
addOptional(p, 'specific_sd', false, @islogical)
addOptional(p, 'specified_sd', 1, @isnumeric)

% Named (unordered) parameters
default_color = false; % If color not specified, let MATLAB decide a default color
is_char_or_numeric = @(x) ischar(x) + isnumeric(x);
addParameter(p, 'color', default_color, is_char_or_numeric)
addParameter(p, 'style', '-', @ischar)
addParameter(p, 'yConstant', 1, @isnumeric)

parse(p, cell_array_of_data, x_column, y_column, lower_bound_x, bin_width_x, upper_bound_x, varargin{:})

current_figure = gcf;

%% 2. Sort y data by their corresponding x data

% 2.1 Concatenate data
number_of_cells = max(size(cell_array_of_data)); % Number of cells
all_data = [];   % initialize all_data array, with unspecified size
for cell_number = 1 : number_of_cells
    all_data = vertcat(all_data, cell_array_of_data{cell_number}(:, :));
end
% all_data (any(isnan(all_data ), 2), :) = []; % Delete rows with nan Dyl 2021-6-17

all_data_sorted = sortrows(all_data, x_column); % sort data according to x column
y_data_first_cell = cell_array_of_data{1}(:, y_column);

% 2.2 Optionally, plot raw data
if(p.Results.plot_raw)
    for temp_cell_number = 1:p.Results.raw_number
        temp_array = cell_array_of_data{temp_cell_number};
        plot(temp_array(:, x_column), temp_array(:, y_column), 'color', p.Results.color)
    end
end

%% 2.3 Bin x and y for all sensors

bin_edges = lower_bound_x : bin_width_x : upper_bound_x;   % Define bins
number_of_bins = length(bin_edges);
binned_data = cell(number_of_bins, 1);    % Initialize cell array for the bins
k = 1; % which row in binned_data to add next row to
b = 0; % which bin you're at
% Loop over all bins
for row = 1 : size(all_data_sorted, 1)
    temp_row = all_data_sorted(row, :);
    if b < length(bin_edges) % Bin the data from bins (1, numBins-1)
        if temp_row(x_column) > bin_edges(b + 1) % If current xCol value is greater than next binEdge % Important 
            k = 1; % Restart count
            b = b + 1;
        end
    end
    k
    b
    binned_data{b}(k, :) = temp_row; % Add this row to the current bin
    k = k + 1;
end



%% 3. Find mean and standard deviation for each bin
bin_statistics = zeros(0, 3); % initialize matrix for meanF, stdevF, CIF. length = number of bins
number_of_bins_minus_one = number_of_bins - 1;
bin_means = zeros(1, number_of_bins_minus_one); % initialize other arrays
bin_count = zeros(1, number_of_bins);
number_of_valid_rows = 1; % counter for how many valid (containing more than 3 data points) rows we have

for temp_bin = 1 : number_of_bins_minus_one
    bin_count(temp_bin) = size(binned_data{temp_bin}, 1);
    
    % If the bin is nearly empty, move on to next bin
    if bin_count(temp_bin) < 3
        continue
    end
    
    % If the bin has valid elements, then compute statistics
    bin_statistics(number_of_valid_rows, 1) = mean(binned_data{temp_bin}(:, y_column));
    bin_statistics(number_of_valid_rows, 2) = std(binned_data{temp_bin}(:, y_column));
    t_statistic = tinv(p.Results.percent_to_right, bin_count(temp_bin)-1); % X% CI t-statistic. X = (1- 2*p.Results.percent_to_right)
    if (p.Results.specific_sd)
         t_statistic = p.Results.specified_sd; % Typically equals 1, so the clouds are +/- one SD
    end

    bin_statistics(number_of_valid_rows, 3) = t_statistic*bin_statistics(number_of_valid_rows, 2);   % 95%CI
    bin_means(number_of_valid_rows) = mean(binned_data{temp_bin}(:, x_column));
    number_of_valid_rows = number_of_valid_rows + 1;
end

% meanBinCount = mean(bin_count); % Print mean number of elements in the bins, for debugging
bin_means = bin_means(1:number_of_valid_rows - 1); % Extract valid means. We incremented number_of_valid_rows one too many times (see loop)

%% Plot Mechanical Response
% Generate the cloud's outline
cloud_bounds(1, :) = bin_statistics(:, 1) + bin_statistics(:, 3); % mean + X% CI
cloud_bounds(2, :) = bin_statistics(:, 1) - bin_statistics(:, 3); % mean - X% CI
[x_patches, y_patches] = get_patches(cloud_bounds(1, :), cloud_bounds(2, :), bin_means);


% Optionally subtract initial value
if(p.Results.subtract_initial)
    y_patches = y_patches - y_data_first_cell(p.Results.initial_row);
    bin_statistics(:, 1) = bin_statistics(:, 1) - y_data_first_cell(p.Results.initial_row);
end

% Plot
if (p.Results.plot_clouds) % Optionally plot cloud
    % Plot Clouds
    if p.Results.clouds_first
        cloud = patch(x_patches, p.Results.yConstant*(y_patches), p.Results.color, 'FaceAlpha', 0.35, 'edgeColor', 'none');
        line = plot(bin_means, p.Results.yConstant*(bin_statistics(:, 1)), '--', 'Color', p.Results.color, 'LineWidth', 2.0, 'DisplayName', 'Mean');
    else
        line = plot(bin_means, p.Results.yConstant*(bin_statistics(:, 1)), '--', 'Color', p.Results.color, 'LineWidth', 2.0, 'DisplayName', 'Mean');
        cloud = patch(x_patches, p.Results.yConstant*(y_patches), p.Results.color, 'FaceAlpha', 0.35, 'edgeColor', 'none');
    end

    % Hide the cloud color in legend, if we don't want to show it
    if ~p.Results.show_cloud_in_legend
        set(get(get(cloud, 'Annotation'), 'LegendInformation'),...
            'IconDisplayStyle', 'off'); % Exclude cloud from legend
    end
else % Just plot mean
    line = plot(bin_means, p.Results.yConstant*(bin_statistics(:, 1)), '--', 'Color', p.Results.color, 'LineWidth', 2.0, 'DisplayName', 'Mean');
end

% figure
% plot(bin_statistics(:, 1))
% plot(bin_statistics(:, 3))

figure(current_figure)

end
