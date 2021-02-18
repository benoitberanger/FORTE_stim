function [ Parameters ] = GetParameters
% GETPARAMETERS Prepare common parameters
global S

if isempty(S)
    %     S.Environement = 'MRI';
    %     S.Side         = 'Left';
    %     S.Task         = 'MRI';
end


%% Echo in command window

EchoStart(mfilename)


%% Paths

% Parameters.Path.wav = ['wav' filesep];


%% Set parameters

%%%%%%%%%%%
%  Audio  %
%%%%%%%%%%%

% Parameters.Audio.SamplingRate            = 44100; % Hz

% Parameters.Audio.Playback_Mode           = 1; % 1 = playback, 2 = record
% Parameters.Audio.Playback_LowLatencyMode = 1; % {0,1,2,3,4}
% Parameters.Audio.Playback_freq           = Parameters.Audio.SamplingRate ;
% Parameters.Audio.Playback_Channels       = 2; % 1 = mono, 2 = stereo

% Parameters.Audio.Record_Mode             = 2; % 1 = playback, 2 = record
% Parameters.Audio.Record_LowLatencyMode   = 0; % {0,1,2,3,4}
% Parameters.Audio.Record_freq             = Parameters.Audio.SamplingRate;
% Parameters.Audio.Record_Channels         = 1; % 1 = mono, 2 = stereo


%%%%%%%%%%%%%%
%   Screen   %
%%%%%%%%%%%%%%
% % Prisma scanner @ CENIR
% Parameters.Video.ScreenWidthPx   = 1024;  % Number of horizontal pixel in MRI video system @ CENIR
% Parameters.Video.ScreenHeightPx  = 768;   % Number of vertical pixel in MRI video system @ CENIR
% Parameters.Video.ScreenFrequency = 60;    % Refresh rate (in Hertz)
% Parameters.Video.SubjectDistance = 0.120; % m
% Parameters.Video.ScreenWidthM    = 0.040; % m
% Parameters.Video.ScreenHeightM   = 0.030; % m

Parameters.Video.ScreenBackgroundColor = [128 128 128]; % [R G B] ( from 0 to 255 )

%%%%%%%%%%%%
%   Text   %
%%%%%%%%%%%%
Parameters.Text.SizeRatio   = 0.07; % Size = ScreenWide *ratio
Parameters.Text.Font        = 'Arial';
Parameters.Text.Color       = [255 255 255]; % [R G B] ( from 0 to 255 )
Parameters.Text.ClickCorlor = [0   255 0  ]; % [R G B] ( from 0 to 255 )

%%%%%%%%%%%%%%%
%   FORTE   %
%%%%%%%%%%%%%%%

% Crosses where the circle will apear, first displayed in the "fixation"
Parameters.Forte.Fixation.spacing_x_ratio     = 0.1;         % from 0 to 1
Parameters.Forte.Fixation.spacing_y_ratio     = 0.1;         % from 0 to 1
Parameters.Forte.Fixation.dimension_ratio     = 0.1;         % from 0 to 1
Parameters.Forte.Fixation.width_height_ratio  = 1/10;        % from 0 to 1
Parameters.Forte.Fixation.color               = [0 0 0 255]; % [R G B a]

% Circles of representing the keys to press, displayed in "instruction"
Parameters.Forte.Instruction.diameter_ratio     = 0.15;           % from 0 to 1
Parameters.Forte.Instruction.thickness_ratio    = 1/10;          % from 0 to 1
Parameters.Forte.Instruction.color              = [255 0 0 255]; % [R G B a]

% Images displayed (and text) representing the reward (+10e or +0.01e), displayed in "outcome"
Parameters.Forte.Outcome.fname_10euro       = '10-euro-note.jpeg';
Parameters.Forte.Outcome.fname_1cent        = '1-cent.png';
Parameters.Forte.Outcome.dimension_ratio    = 0.3;                 % from 0 to 1
Parameters.Forte.Outcome.y_offcet_ratio_img = 0.6;                 % from 0 to 1
Parameters.Forte.Outcome.y_offcet_ratio_txt = 0.3;                 % from 0 to 1
Parameters.Forte.Outcome.font_color         = [128 0 0 255]; % [R G B] ( from 0 to 255 )
Parameters.Forte.Outcome.font_size_ratio    = 0.3;

%%%%%%%%%%%%%%
%  Keybinds  %
%%%%%%%%%%%%%%

KbName('UnifyKeyNames');

% Parameters.Keybinds.TTL_t_ASCII          = KbName('t'); % MRI trigger has to be the first defined key
Parameters.Keybinds.emulTTL_s_ASCII      = KbName('SPACE');
Parameters.Keybinds.Stop_Escape_ASCII    = KbName('ESCAPE');

Parameters.Fingers.Vect(1) = KbName('c');
Parameters.Fingers.Vect(2) = KbName('f');
Parameters.Fingers.Vect(3) = KbName('t');
Parameters.Fingers.Vect(4) = KbName('h');
Parameters.Fingers.Vect(5) = KbName('n');
Parameters.Fingers.Names = {'C' 'F' 'T' 'H' 'N'};


%% Echo in command window

EchoStop(mfilename)


end