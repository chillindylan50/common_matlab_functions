function [ data_cells ] = import_instron_data( folder, file_prefix, file_suffixes, varargin )
% import_instron_data: import instron data
%   [ data_cells ] = import_instron_data( folder, file_prefix, file_suffixes, varargin )
%   Import data files located in a given folder, with a filename pattern of
%   "[file_prefix][file_suffix].csv"
%
%   Required inputs:
%   folder = folder containing your data
%   file_prefix = prefix that is common to each file
%   file_suffixes = suffix for each individual file name. Assumed they're
%   given as cells of strings
%
%   Optional inputs  (positional):
%   N/A
%
%   Optional Parameters (not positional, specified by an identifying string):
%   N/A

% TODO:
% N/A

% Function parser described here https://www.mathworks.com/help/matlab/matlab_prog/parse-function-inputs.html
% In brief: add[type](inputParser, name, check function)
p = inputParser;
addRequired(p, 'folder', @ischar)
addRequired(p, 'file_prefix', @ischar)
addRequired(p, 'file_suffixes', @ischar)
% addParameter(p, 'skip_first', false, @islogical)

data_cells = cell(length(file_suffixes), 1);
cell_index = 1;
for file = file_suffixes
    file = file{1}
    data_cells{cell_index}(:, :) = xlsread([folder file_prefix file '.csv']);
    cell_index = cell_index + 1;
end