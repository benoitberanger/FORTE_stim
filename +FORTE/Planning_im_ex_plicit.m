function [ EP , Parameters ] = Planning_im_ex_plicit
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
Parameters.randomized_triplet_reward = randomized_triplet_reward;


%% Define a planning <--- paradigme


% Create and prepare
header = { 'event_name', 'onset(s)', 'duration(s)', 'triplet', 'reward' '#block' '#trial' 'totalmaxreward'};
EP     = EventPlanning(header);

% NextOnset = PreviousOnset + PreviousDuration
NextOnset = @(EP) EP.Data{end,2} + EP.Data{end,3};


% --- Start ---------------------------------------------------------------

EP.AddStartTime('StartTime',0);

% --- Stim ----------------------------------------------------------------

totalmaxreward = 0;

for iBlock = 1 : Parameters.nBlock
    
    
    if iBlock == 1
        
        shuffled_triplet_reward = Shuffle(randomized_triplet_reward,2);
        
    else % ensure the first triplet of the new block is different from the last triplet of the last block
        
        prev_triplet = shuffled_triplet_reward{end,1};
        
        shuffled_triplet_reward = Shuffle(randomized_triplet_reward,2);
        first_triplet = shuffled_triplet_reward{1,1};
        condition = all(prev_triplet == first_triplet);
        
        while condition
            shuffled_triplet_reward = Shuffle(randomized_triplet_reward,2);
            first_triplet = shuffled_triplet_reward{1,1};
            condition = all(prev_triplet == first_triplet);
        end
        
    end
    
    for iTrialinBlock = 1 : size(shuffled_triplet_reward,1)
        
        switch shuffled_triplet_reward{iTrialinBlock,2}
            case 'high'
                totalmaxreward = totalmaxreward + 10.00;
            case 'low'
                totalmaxreward = totalmaxreward + 00.01;
        end
        
        other_info = { shuffled_triplet_reward{iTrialinBlock,1} shuffled_triplet_reward{iTrialinBlock,2} ...
            iBlock iTrialinBlock totalmaxreward};
        EP.AddPlanning([ { 'Fixation'    NextOnset(EP) Parameters.FixationDuration } other_info ])
        EP.AddPlanning([ { 'Instruction' NextOnset(EP)                           0 } other_info ])
        EP.AddPlanning([ { 'Response'    NextOnset(EP)                           0 } other_info ])
        EP.AddPlanning([ { 'Outcome'     NextOnset(EP) Parameters.OutcomeDuration  } other_info ])
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