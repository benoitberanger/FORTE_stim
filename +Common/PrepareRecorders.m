% function [ ER, RR, KL, SR ] = PrepareRecorders( EP )
function [ ER, RR, KL, BR ] = PrepareRecorders( EP, Parameters )
global S

%% Prepare event record

% Create
ER = EventRecorder( EP.Header , EP.EventCount );

% Prepare
ER.AddStartTime( 'StartTime' , 0 );


%% Response recorder

% Create
RR = EventRecorder( { 'event_name' , 'onset(s)' , 'duration(s)' , 'content' } , 5000 ); % high arbitrary value : preallocation of memory

% Prepare
RR.AddStartTime( 'StartTime' , 0 );


% %% Sample recorder
% 
% switch S.Task
%     case 'PNEU'
%         SR = SampleRecorder( { 'time (s)', 'X (pixels)', 'Y (pixels)'} , round(EP.Data{end,2}*S.PTB.FPS*1.20) ); % ( duration of the task +20% )
%     case 'ELEC'
%         SR = SampleRecorder( { 'time (s)', 'channel 7 - Nerve' 'channel 8 - Skin'} , round(EP.Data{end,2}*S.PTB.FPS*1.20) ); % ( duration of the task +20% )
% end


%% Behaviour recorder

BR = EventRecorder( {'idx', 'iBlock', 'iTrial', 'triplet', 'reward', 'maxGain', 'gain', 'is_good', 'is_bad', 'is_maxtime',...
    'onset_fixation', 'onset_instruction', 'onset_key_1','onset_key_2','onset_key_3','onset_outcome'}, Parameters.nBlock*10);


%% Prepare the logger of MRI triggers

KbName('UnifyKeyNames');

KL = KbLogger( ...
    [ struct2array(S.Parameters.Keybinds)         S.Parameters.Fingers.Vect  ] ,...
    [ KbName(struct2array(S.Parameters.Keybinds)) S.Parameters.Fingers.Names ] );

% Start recording events
KL.Start;


end % function
