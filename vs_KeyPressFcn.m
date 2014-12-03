function vs_KeyPressFcn(hObject, eventdata, handles)

global all_responses trial_nr

global width height im
% Object display properties 
global  margin mindist long short 

% Globals for the sound
global samplingrate file delay

% Data recording and program flow
global parameters all_responses trial_nr
global breathe semaphore

% Globals for parameter information
global kinds_of_objects
global speak_orientation_first 
% Globals to access the parameters at their appropriate index
global sti_con_index sti_type_index set_size_index block_index 

reactiontime = toc;
currentkey =  double(get(hObject,'CurrentKey'));
disp('Key is pressed');
right_key = false;
right_response_key = false;
if ( isequal(get(hObject,'CurrentKey'),'1') || isequal(get(hObject,'CurrentKey'),'0') ||...
        isequal(get(hObject,'CurrentKey'),'space'))
	right_key = true;
end
if ( isequal(get(hObject,'CurrentKey'),'1') || isequal(get(hObject,'CurrentKey'),'0') )
    right_response_key = true;
end

if ( semaphore == false && right_key == true )
    semaphore = true; % Prevent new key presses while processing this
    
    if (trial_nr <= length(parameters)) % Are we done yet?
        
        if ( breathe && right_response_key )
            draw_white(); % flash display white
            disp('Recording data for trial_nr');
            disp(trial_nr);
            all_responses = [all_responses; ...
                parameters(trial_nr,:) currentkey(1) reactiontime];
            trial_nr = trial_nr + 1;
            breathe = false;
            
        elseif ( right_response_key == false && breathe == false )
            draw_fixation_cross();
            
            % **** Draw Experiment Display
            % reset im to white
            im = uint8(zeros(height,width,3)+255); 
            
            % Compute the desired number of objects of each kind
            % number of objects of each kind 
            object_collection = zeros(kinds_of_objects,1);
            remaining_objects = parameters( trial_nr, set_size_index );
            
            % stimulus_type is from 1 to kinds_of_objects
            stimulus_type = parameters( trial_nr, sti_type_index );
            
            if ( parameters( trial_nr, sti_con_index ) )
                object_collection( stimulus_type ) = 1;
                remaining_objects = remaining_objects - 1;
            end
            
            additional_objects = mod(remaining_objects, kinds_of_objects-1);
            remaining_objects  = remaining_objects - additional_objects;
            
            for i = 0:2
               object_type = mod(stimulus_type + i,4) + 1;
               object_collection( object_type ) = remaining_objects / (kinds_of_objects-1) ;
            end
            % the last other object_type (other than the stimulus)
            % gets additional objects, depending on whether set_size is
            % divisible by 3
            object_collection( object_type ) = object_collection( object_type ) + additional_objects;
            
            %disp('Showing objects rv rh gv gh');
            create_display(object_collection(1), object_collection(2),...
                           object_collection(3),object_collection(4)); 
            
            % Fetch and play sound
            % Stimulus kinds are s.t. type 1 = rv, type 2 =  rh,
            % type 3 = gv and type 4 = gh
            % the alphabelitcal file order is, however, gh,gv,rh,rv            
            stimuli_to_file_order = [4 3 2 1];
            
            if speak_orientation_first
                % Need files with *o.wav, which are files 2,4,6,8
                filenumber = 2 + (stimuli_to_file_order(stimulus_type)-1)*2;
            else % if not then default to color first
                % Need files with *c.wav, which are files 1,3,5,7
                % (gh,gv,rh,rv)
                filenumber = 1 + (stimuli_to_file_order(stimulus_type)-1)*2;
            end
            
            player = audioplayer(file{filenumber}, samplingrate);
            % Critical timing paramter that might need to be
            % changed depending on OS and machinery
            wa = ( length(file{filenumber}) / samplingrate ) - 0.18; % Default delay
            % add additional delay
            wa = wa + delay;
            play(player)
            disp('Pause by ');
            disp(wa);
            pause(wa)
            
            % Present stimulus
            %imp = permute(im,[2 1 3]);  % Turn the image for presentation
            breathe = true;
            image(im)
            axis off
            drawnow
            tic
            
        end; % breathe
    else % End the experiment, all trials finished
        quit_experiment();
    end;
    semaphore = false; % Allow new keypresses again
end; % semaphore