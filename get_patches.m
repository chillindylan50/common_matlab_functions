function [ complete_x_values, complete_y_values ] = get_patches( top_y_values, bottom_y_values, x_values )
% get_patches Gets a sequence of vertices to outline the input points, which 
% are typically confidence intervals of bins for plotting "clouds". Called by plotClouds.
%   [ complete_x_values, complete_y_values ] = get_patches( top_y_values,
%   bottom_y_values, x_values ) Gets a sequence of vertices to outline the
%   input points defined by the three inputs, (top_y_values, bottom_y_values,
%   and x_values) - which  are typically confidence intervals of bins for 
%   plotting "clouds".
%
%   Required Inputs: 
%   top_y_values = vector with the y values of the points on the top of your
%   desired cloud. *Assumes this vector is in "increasing corresponding
%   x value" order.*
%   bottom_y_values = vector with the y values of the points on the bottom of
%   your desired cloud. *Assumes this vector is in "increasing corresponding
%   x value" order.*
%   x_values = common x values of the points of your desired cloud. *Assumes
%   you input a y value for the top and bottom at each desired x location.*
%
%   Optional inputs  (positional):
%   N/A
%   Optional Parameters (not positional, specified by an identifying string):
%   N/A
%
%   Outputs:
%   complete_x_values, complete_y_values = complete coordinates for your cloud.

% Check that all inputs were vectors.
if ~isvector(top_y_values)
    warning('Inputs to get_patches should be vectors. "top_y_values" is not a vector')
elseif ~isvector(bottom_y_values)
    warning('Inputs to get_patches should be vectors. "bottom_y_values" is not a vector')
elseif ~isvector(x_values)
    warning('Inputs to get_patches should be vectors. "x_values" is not a vector')
end
length = max(size(x_values)); % find length of vector

% Flip x and bottom y, so we are an the order that the "patch" function
% expects: clockwise. (Alternately, we could have gone counterclockwise.)
for offset = 1:length
    reverse_x_values(offset) = x_values(length - offset + 1);
    reverse_bottom_y_values(offset) = bottom_y_values(length - offset + 1);
end

% Create output vectors by combining top and bottom points.
complete_x_values = [x_values, reverse_x_values];
complete_y_values = [top_y_values, reverse_bottom_y_values];
end
