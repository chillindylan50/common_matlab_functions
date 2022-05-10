function [ result ] = plot_all_cols( in_array, x_data_column, varargin )
% plot_all_cols Plot all columns of data
%   Plot all columns of [in_array], with the x column specified by
%   [x_data_column]. Optional arguments available through varargin.
%
% Required inputs:
% in_array = data to be plotted
% x_data_column = column to be used as x-coordinate for plotting
%
% Optional inputs (positional):
% subtract_mean = subtract mean from data prior to plotting
% COLUMNS = what columns to plot
%
% Optional Parameters (not positional, specified by an identifying string):
% COLORS = what colors to plot with. Row in an array (char, or 1x3 numeric
% for each column
% STYLE = style of symbol you want plotted. Ex: '-' for line, '--' broken
% line

% Function parser https://www.mathworks.com/help/matlab/matlab_prog/parse-function-inputs.html
% In brief: add[type](inputParser,name,check function)
p = inputParser;
addRequired(p, 'in_array', @isnumeric)
addRequired(p, 'x_data_column', @isnumeric)
addOptional(p, 'subtract_mean', true, @islogical)
addOptional(p, 'columns', 1:size(in_array,2), @isnumeric)

% If we know there are four sensor reading columns, assign default colors
if size(in_array,2) == 5
    defaultColors = ['r'; 'g'; 'b'; 'k'];
else
    defaultColors = false; % Else, let MATLAB decide a default color
end
is_char_or_numeric = @(x) ischar(x) + isnumeric(x);
addParameter(p, 'colors', defaultColors, is_char_or_numeric)
addParameter(p, 'style','-', @ischar)

parse(p,in_array, x_data_column, varargin{:})

hold on
% Subtract mean
if p.Results.subtract_mean
    time = in_array(:, x_data_column);
    in_array = in_array - repmat(mean(in_array), size(in_array, 1), 1);;
    in_array(:, x_data_column) = time;
end

% Plot all columns. Use colors as specified in "if size..." block, above
number_of_curves_plotted = 1;
for ii = p.Results.columns
    if ii ~= x_data_column
        if islogical(p.Results.colors)
            % If no color was specified, and array doesn't have five
            % columns, let MATLAB decide color
            plot(in_array(:, x_data_column), in_array(:, ii), p.Results.style);
        else
            % If color was specified by user and/or MATLAB, use it!
            plot(in_array(:, x_data_column), in_array(:, ii), p.Results.style, 'Color', p.Results.colors(number_of_curves_plotted, :));
        end
        number_of_curves_plotted = number_of_curves_plotted + 1;
    end
end

end
