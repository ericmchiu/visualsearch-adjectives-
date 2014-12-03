% Code for conducting Linguistic Visual Search experiments

% A table of stimuli is prepared, and for each execution of the function
% vs_KeyPressFcn a response table is prepared and by the end of the
% experiment this table is written to a file with the prefix "subject"

% Use any key to get the next stimuli and 0 and 1 to indicate absence and
% presence

% Display related information
global width height im
global vs_figure
% Object display properties 
global  margin mindist long short 

% Globals for the sound
global samplingrate file delay

% Data recording & program flow
global parameters all_responses trial_nr
global breathe semaphore

% Globals for parameter information
global kinds_of_objects
global speak_orientation_first 
% Globals to access the parameters at their appropriate index
global sti_con_index sti_type_index set_size_index block_index 


% CONDITIONS SETUP
%**************************
% FIXED CONDITIONS
speak_orientation_first = false;
samplingrate = 22050;
delay = -0.8; % additional delay in seconds between sound and object display

% Variable CONDITIONS (AKA parameters)
% Stimulus object can be present or absent
stimulus_conditions = 2; % present or absent
% Object can one of four kinds
kinds_of_objects = 4; %kind 1,2,3 and 4;
% Once the stimulus is one kinds, the noise is one out of the OTHER kinds
% Total number of objects can be one of 2,3 or 4 sizes
setsizes = [5 10 15 20]; % Set sizes

% How many blocks should the experiment run for?
% Each block contains every conditions exactly once, in random order
number_of_blocks = 1;                         

% One parameter for stimulus condition, one for kind of stimulus, one for
% kind of noise, one for setsize; in the order as defined above
% fifth parameter is the block number
num_parameters = 5;

% These variables determine the index a parameter gets insinde 'parameters'
sti_con_index = 1;
sti_type_index = 2;
set_size_index = 4;
block_index = 5;

%**************************

% CONDITIONS COMPUTED AUTOMATICALLY
number_of_set_sizes = size(setsizes,2);
number_of_conditions = ...
    stimulus_conditions * kinds_of_objects * number_of_set_sizes * number_of_blocks;

parameters = zeros(number_of_conditions, num_parameters);
for i = 1:number_of_conditions
   parameters(i, sti_con_index )    = mod(i, stimulus_conditions );
   parameters(i, sti_type_index )   = 1 + mod( floor( (i-1) / stimulus_conditions ) ,kinds_of_objects);
   parameters(i, set_size_index )   = 1 + mod( floor( (i-1) / (stimulus_conditions*kinds_of_objects)), number_of_set_sizes);
   parameters(i, block_index )      = 1 + mod( floor( (i-1) / (stimulus_conditions*kinds_of_objects*number_of_set_sizes)), number_of_blocks);
end
for i = 1:number_of_conditions
   parameters(i, set_size_index) = setsizes( parameters(i,4) );
end

% this randomly permutes the conditions within each block
% NOT across blocks
block_size = number_of_conditions / number_of_blocks;
for i = 0:(number_of_blocks-1)
    from = 1 + i * block_size;
    to = (i+1) * block_size;
    parameters( from - 1 + randperm(block_size),: ) = parameters(from:to,:);
end

% Gather display information
screensize  = get(0,'ScreenSize');          % Get the screen size
width       = screensize(3);                % Width of display
height      = screensize(4)-20;             % Height of display minus something for the handle

margin      =  10;                          % Minimal distance of elemenent from sides
mindist     =  10;                          % Minimal distance between elements
long        =  80;                          % Long side of element
short       =  20;                          % Short side of element

%Loading sound files
files = dir('sound/*.wav');                   % Read the sound files
for i=1:length(files)
    file{i} = wavread(['sound/' files(i).name]);
end

% Initialize variables
disp('Initialize variables');
semaphore       = false;                        % Only process one keypress at a time
breathe         = false;                        % Subject is either active or breathing
all_responses   = [];                           % Table to record all responses in
trial_nr        = 1;                            % index to count trials

% Creates a figure (i.e. a display) associates the vs_KeyPressFcn
% this function is executed every time the user hits a key
disp('Calling figure');
vs_figure = figure(...
    'Position',[0 0 width height],...
    'outerposition',[0 0 width height],...
    'KeyPressFcn',@vs_KeyPressFcn_practice,...
    'NumberTitle','off', ...
    'MenuBar','none',...
    'ToolBar','none');  
% Setting up some display properties
axis off
axes('position',[0  0  1  1])

text(0.05,.8,'You are about to start the practice block.','Fontsize', 50)
text(0.05,.7,'Please respond as quickly and accurately as possible.','Fontsize', 50)
text(0.2,.6,'If the object is absent press "no" and if the object is present press "yes."','Fontsize', 30)
text(0.2,.55,'After each trial, press the "space bar" to continue.','Fontsize', 30)
text(0.2,.5,'When you are ready, press the "space bar" to begin.','Fontsize', 30)
text(0.3,.40,'Notify the experimenter','Fontsize', 50)
text(0.3,.30,'when the practice block is over.','Fontsize', 50)

tic