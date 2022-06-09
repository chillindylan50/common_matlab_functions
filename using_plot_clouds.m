% Description of file

% Maintained by: First Last, last modified YYYY/MM/DD

% Whitespace style guide
% Before section: (%%) | Three lines
% Before major subsection. | Two lines
% Before minor subsection. | One line



%% 1. Prepare MATLAB
clc
close all
clearvars



%% 2. Global Variables
% 2.1 colors = {'0kpa':'b'}; % Sample color dictionary

disp_col = 1;
stress_col = 2;
min_disp = 0;
percent_to_right = 0.05;
plot_raw_status = false;
bin_width = 0.5;


%% 3. Generate Some random data
% Assumes: five files (instron runs) per sample. 
% Assumes "files" gives specimens the following indices: Specimen A = 1:5, B = 6:10, C = 11:15

x = linspace(1, 10, 100)';
y = x * 5 + 1;
y_noised = [x, y + rand(100, 1)];
y_noised_2 = [x, y + rand(100, 1)];
y_noised_3 = [x, y + rand(100, 1)];


%% 5. Plot Data
% How internally consistent are the specimens?

% Prepare figures
figure(1)
clf
hold on
% title('All Data')
xlabel('Displacement (mm)')
ylabel('Shear Stress (kPa)')
xlim([0 10])
ylim([0 60])


psi_0 = plot_clouds({y_noised, y_noised_2, y_noised_3}, disp_col, stress_col, min_disp-1, bin_width, 11, 'color', [1 0 0], 'subtract_initial', false, 'percent_to_right', percent_to_right, 'specific_sd', true, 'plot_raw', plot_raw_status);
% plot(temp_array(:, x_column), temp_array(:, y_column), 'color', p.Results.color)


% Finish up
disp('Done plotting one figure per specimen type, with all specimens at all pressures')


%% Auto Arrange Figures
autoArrangeFigures()

