function [ EP , Parameters ] = Planning
global S

if nargout < 1 % only to plot the paradigme when we execute the function outside of the main script
    S.OperationMode = 'Acquisition';
end


%% Paradigme

% switch S.OperationMode
%     case 'Acquisition'
        Parameters.FixationDuration   = 1.000; % s
        Parameters.OutcomeDuration    = 1.500; % s
        Parameters.nBlock             = 15;
        Parameters.MaxTime            = 10;    % s
        Parameters.DisableLastGoodKey = 0.500; % s
%     case 'FastDebug'
%         
%     case 'RealisticDebug'
%         
% end


%% triplet

triplet = {
    %1 2 3 4 5
    [0 0 1 1 1]
    [0 1 1 0 1]
    [1 1 0 0 1]
    [1 0 1 0 1]
    [1 0 0 1 1]
    [0 1 0 1 1]
    [1 0 1 1 0]
    [0 1 1 1 0]
    [1 1 0 1 0]
    [1 1 1 0 0]
    };

% just to check
assert( all(sum(cell2mat( triplet ),1) == 6) )
assert( all(sum(cell2mat( triplet ),2) == 3) )

reward = {
    'high'
    'high'
    'high'
    'high'
    'high'
    'low'
    'low'
    'low'
    'low'
    'low'
    };

% Shuffle
randomized_triplet = Shuffle(triplet);
randomized_reward  = Shuffle(reward);

% Associate triplet with reward
randomized_triplet_reward = [randomized_triplet randomized_reward];


%% Define a planning <--- paradigme


% Create and prepare
header = { 'event_name', 'onset(s)', 'duration(s)', 'triplet', 'reward'};
EP     = EventPlanning(header);

% NextOnset = PreviousOnset + PreviousDuration
NextOnset = @(EP) EP.Data{end,2} + EP.Data{end,3};


% --- Start ---------------------------------------------------------------

EP.AddStartTime('StartTime',0);

% --- Stim ----------------------------------------------------------------

for iBlock = 1 : Parameters.nBlock
    
    shuffled_triplet_reward = Shuffle(randomized_triplet_reward,2);
    
    for trial_in_block = 1 : size(shuffled_triplet_reward,1)
        EP.AddPlanning({ 'Fixation'    NextOnset(EP) Parameters.FixationDuration randomized_triplet_reward{trial_in_block,1} randomized_triplet_reward{trial_in_block,2} })
        EP.AddPlanning({ 'Instruction' NextOnset(EP)                           0 randomized_triplet_reward{trial_in_block,1} randomized_triplet_reward{trial_in_block,2} })
        EP.AddPlanning({ 'Response'    NextOnset(EP)                           0 randomized_triplet_reward{trial_in_block,1} randomized_triplet_reward{trial_in_block,2} })
        EP.AddPlanning({ 'Outcome'     NextOnset(EP) Parameters.OutcomeDuration  randomized_triplet_reward{trial_in_block,1} randomized_triplet_reward{trial_in_block,2} })
    end
    
end

% --- Stop ----------------------------------------------------------------

EP.AddStopTime('StopTime',NextOnset(EP));


%% Display

% To prepare the planning and visualize it, we can execute the function
% without output argument

if nargout < 1
    
    fprintf( '\n' )
    fprintf(' \n Total stim duration : %g seconds \n' , NextOnset(EP) )
    fprintf( '\n' )
    
    EP.Plot
    
end


end % function