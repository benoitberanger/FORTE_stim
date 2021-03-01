function [ EP , Parameters ] = Planning_forced_choice
global S

if nargout < 1 % only to plot the paradigme when we execute the function outside of the main script
    S.OperationMode = 'Acquisition';
end


%% Paradigme

% switch S.OperationMode
%     case 'Acquisition'
Parameters.FixationDuration   = 1.000; % s
Parameters.MaxTime            = 3;    % s
Parameters.nBlock             = 1;
%     case 'FastDebug'
%
%     case 'RealisticDebug'
%
% end


%% triplet

randomized_triplet_reward = S.randomized_triplet_reward;


%% Define a planning <--- paradigme


% Create and prepare
header = { 'event_name', 'onset(s)', 'duration(s)', 'triplet', 'reward' '#block' '#trial' 'totalmaxreward'};
EP     = EventPlanning(header);

% NextOnset = PreviousOnset + PreviousDuration
NextOnset = @(EP) EP.Data{end,2} + EP.Data{end,3};


% --- Start ---------------------------------------------------------------

EP.AddStartTime('StartTime',0);

% --- Stim ----------------------------------------------------------------


for iTrialinBlock = 1 : size(randomized_triplet_reward,1)
    
    other_info = { randomized_triplet_reward{iTrialinBlock,1} randomized_triplet_reward{iTrialinBlock,2} ...
        0 0 0};
    EP.AddPlanning([ { 'Fixation'     NextOnset(EP) Parameters.FixationDuration } other_info ])
    EP.AddPlanning([ { 'ForcedChoice' NextOnset(EP)                           0 } other_info ])
    
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