% generate_scrolling_data_vid.m

% This file takes a .csv file as input, and generates a video with the data scrolling in from the right-hand side. Variables/objects that a typical user would want to modify are marked with "% USER %"

% Maintained by: Dylan Shah, last modified 2021/1/19



%% 1. Initialize MATLAB
clc; clear; close all;



%% 2. Plot and record video %%%%%%%%%%%%%%%%%%%%
%% 2.1 Select video settings % USER (Whole section) % 
movie_name     = 'data_video.avi';
frame_rate     = 60; % How many frames per second for the output video
x_size         = 800; % Video X resolution [pixels]
y_size         = 800/2.5; % Video Y resolution [pixels]
time_window    = 5000; % Window width [ms]
data_rate      = 5000; % How many miliseconds of data to plot per second of video (1000 for realtime) [msD/sV]
data_duration  = 50000;  % End timestep that should be plotted [ms]. If > maximum timestep in the data, all data will be plotted.


%% 2.2 Import CSV Data
% Must have ASCII encoding or it will fail with error
% "Trouble reading 'Numeric' field from file" 
% Change the filename, and the columns below for sensor, control_signal, etc.
csv_data = csvread('data.csv'); % USER % The data we want to plot.
data_length = size(csv_data, 1); % Length of our data (number of timesteps)

timestamps = csv_data(:,1);
timestamps = timestamps - timestamps(1); % Set beginning time to 0 
max_time = timestamps(data_length);

sensor_data = csv_data(:,6);
control_signal = csv_data(:,7);
min_y_value = min(control_signal)*0.8; % Min data value to show on plot. % USER %
max_y_value = max(control_signal)*1.2; % Max data value to show on plot. % USER %


%% 2.3 Initialize video writer
data_period = data_rate / frame_rate; % Time ploted per frame [ms]
points_per_frame = time_window / data_period;
% Example: 5000 [msD/sV] / 60 [frame/sV] = 83 [msD/frame]
our_video_writer = VideoWriter(movie_name);
our_video_writer.FrameRate = frame_rate;
open(our_video_writer);

% 2.4 Interpolate data at time-values corresponding to our framerate
interpolated_times = 0: data_period: max_time;
sensor_data_interpolated = interp1(timestamps, sensor_data, interpolated_times);
control_signal_interpolated = interp1(timestamps, control_signal, interpolated_times);
n_frames = size(interpolated_times, 2);


% 2.5 Generate frames for the video
our_figure = figure('pos', [10 10 x_size y_size]); % Set up figure for plotting (and the video frames)
frame_number = 0;
for frame = 1:n_frames
    current_time = interpolated_times(frame);

    % If we have reached the max movie duration, end program
    if current_time > data_duration
        break;
    end
    
    % Only write a frame if enough time passed (this gets proper framerate)
    if current_time > floor(frame_number*data_period)
        frame_number = frame_number + 1;
        
        % Print after generating each second of video, for predicting remaining time
        if (rem(frame_number, frame_rate) == 0)
            seconds_remaining = (data_duration - current_time) / 1000
        end
        
        % Shift data so it comes in from the right side (0 is @ right)
        shifted_times = interpolated_times - current_time;
        
        % Find the data corresponding to our current window. 
        % For first few frames, we don't have enough "previous" data to fill the window
        if frame < points_per_frame + 1
            window_beginning = 1;
        else
            window_beginning = frame - points_per_frame;
        end
        time_truncated = shifted_times(window_beginning:frame);
        sensor_truncated = sensor_data_interpolated(window_beginning:frame);
        control_truncated = control_signal_interpolated(window_beginning:frame);
        
        % Let matlab clear figure, and plot new data
        hold off; 
        plot(time_truncated, sensor_truncated, 'LineWidth', 1.5);
        hold on;
        plot(time_truncated, control_truncated, 'LineWidth', 1.5);
        
        % Format the Plot
        ylabel("Curvature");
        legend("Sensor Data", "Command Data", 'Location', 'southoutside', 'orientation', 'horizontal');
        set(gca, 'fontsize', 16)
        % hold axes constant
        axis([-time_window 0 min_y_value max_y_value]); % only show current window
        % Hide the bottom tickmarks
        set(gca, 'XTick', []);
        set(gca, 'XTickLabel', {' '})
        
        % Show figure and save frame to the video
        drawnow
        % pause(framePeriod); % Pause, so we plot speed matches video speed
        current_frame = getframe(our_figure); % Get the current figure as a frame
        writeVideo(our_video_writer, current_frame.cdata) % Save the frame
    end
end


% Finish Up
close(our_video_writer)
temp_string = sprintf('Done. Video output as %s', movie_name);
disp(temp_string)