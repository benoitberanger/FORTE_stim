function main_FORTE(hObject, ~)
% FORTE_main is the main program, calling the different tasks and
% routines, accoding to the paramterts defined in the GUI


%% GUI : open a new one or retrive data from the current one

if nargin == 0
    
    gui_FORTE;
    
    return
    
end

handles = guidata(hObject); % retrieve GUI data


%% MAIN : Clean the environment

clc
sca
rng('default')
rng('shuffle')


%% MAIN : Initialize the main structure

global S
S               = struct; % S is the main structure, containing everything usefull, and used everywhere
S.TimeStamp     = datestr(now, 'yyyy-mm-dd HH:MM'); % readable
S.TimeStampFile = datestr(now, 30                ); % to sort automatically by time of creation


%% GUI : Task selection

switch get(hObject,'Tag')
    
    case 'pushbutton_FORTE_implicit'
        Task = 'FORTE_implicit';
        
    case 'pushbutton_FORTE_explicit'
        Task = 'FORTE_explicit';
        
    case 'pushbutton_FORTE_forced_choice'
        Task = 'FORTE_forced_choice';

    case 'pushbutton_EyelinkCalibration'
        Task = 'EyelinkCalibration';
        
    otherwise
        error('FORTE:TaskSelection','Error in Task selection')
end

S.Task = Task;


% %% GUI : Environement selection
%
% switch get(get(handles.uipanel_Environement,'SelectedObject'),'Tag')
%     case 'radiobutton_MRI'
%         Environement = 'MRI';
%     case 'radiobutton_Practice'
%         Environement = 'Practice';
%     otherwise
%         warning('FORTE:ModeSelection','Error in Environement selection')
% end
%
% S.Environement = Environement;


%% GUI : Save mode selection

switch get(get(handles.uipanel_SaveMode,'SelectedObject'),'Tag')
    case 'radiobutton_SaveData'
        SaveMode = 'SaveData';
    case 'radiobutton_NoSave'
        SaveMode = 'NoSave';
    otherwise
        warning('FORTE:SaveSelection','Error in SaveMode selection')
end

S.SaveMode = SaveMode;


%% GUI : Mode selection

switch get(get(handles.uipanel_OperationMode,'SelectedObject'),'Tag')
    case 'radiobutton_Acquisition'
        OperationMode = 'Acquisition';
    case 'radiobutton_FastDebug'
        OperationMode = 'FastDebug';
    case 'radiobutton_RealisticDebug'
        OperationMode = 'RealisticDebug';
    otherwise
        warning('FORTE:ModeSelection','Error in Mode selection')
end

S.OperationMode = OperationMode;


%% GUI + MAIN : Subject ID & Run number

SubjectID = get(handles.edit_SubjectID,'String');

if isempty(SubjectID)
    error('FORTE:SubjectIDLength','\n SubjectID is required \n')
end

% Prepare path
DataPath = [fileparts(pwd) filesep 'data' filesep SubjectID filesep];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Special case, fetch last data for "forced_choice"

switch Task
    
    case 'FORTE_implicit'
        % pass
        
    case 'FORTE_explicit'
        % pass
        
    case 'FORTE_forced_choice'
        
        assert( exist(DataPath,'dir') == 7, '%s dir does not exist. Run "implicit" or "explicit first"', DataPath )
        
        LastFileName = get(handles.text_LastFileName,'String');
        if isempty(LastFileName)
            LastFileName = uigetfile( sprintf( '%s*mat',DataPath ) );
            if  LastFileName==0
                warning('file not selected')
                return
            else
                set(handles.text_LastFileNameAnnouncer, 'Visible','on'         )
                set(handles.text_LastFileName         , 'Visible','on'         )
                set(handles.text_LastFileName         , 'String' , LastFileName)
            end
        end
        
        content = load( fullfile(DataPath,LastFileName ) );
        S.randomized_triplet_reward = content.S.TaskData.Parameters.randomized_triplet_reward;
        
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


if strcmp(SaveMode,'SaveData') && strcmp(OperationMode,'Acquisition')
    
    if ~exist(DataPath, 'dir')
        mkdir(DataPath);
    end
    
end

% DataFile_noRun = sprintf('%s%s_%s_%s_%s', DataPath, S.TimeStampFile, SubjectID, Environement, Task );
DataFile_noRun = sprintf('%s_%s', SubjectID, Task );

% Auto-incrementation of run number
% -------------------------------------------------------------------------
% Fetch content of the directory
dirContent = dir(DataPath);

% Is there file of the previous run ?
previousRun = nan(length(dirContent)-2,1);
for f = 3 : length(dirContent) % avoid . and ..
    runNumber = regexp(dirContent(f).name,[DataFile_noRun '_run?(\d+)'],'tokens');
    if ~isempty(runNumber) % yes there is a file
        runNumber = runNumber{1}{:};
        previousRun(f) = str2double(runNumber); % save the previous run numbers
    else % no file found
        previousRun(f) = 0; % affect zero
    end
end

LastRunNumber = max(previousRun);
% If no previous run, LastRunNumber is 0
if isempty(LastRunNumber)
    LastRunNumber = 0;
end

RunNumber = LastRunNumber + 1;
% -------------------------------------------------------------------------

DataFile     = sprintf('%s%s_%s_%s_run%0.2d', DataPath, S.TimeStampFile, SubjectID, Task, RunNumber );
DataFileName = sprintf(  '%s_%s_%s_run%0.2d',           S.TimeStampFile, SubjectID, Task, RunNumber  );

S.SubjectID     = SubjectID;
S.RunNumber     = RunNumber;
S.DataPath      = DataPath;
S.DataFile      = DataFile;
S.DataFileName  = DataFileName;


%% MAIN : Controls for SubjectID depending on the Mode selected

switch OperationMode
    
    case 'Acquisition'
        
        % Empty subject ID
        if isempty(SubjectID)
            error('FORTE:MissingSubjectID','\n For acquisition, SubjectID is required \n')
        end
        
        % Acquisition => save data
        if ~get(handles.radiobutton_SaveData,'Value')
            warning('FORTE:DataShouldBeSaved','\n\n\n In acquisition mode, data should be saved \n\n\n')
        end
        
end


%% GUI : Parallel port ?

switch get( handles.checkbox_ParPort , 'Value' )
    
    case 1
        ParPort = 'On';
    case 0
        ParPort = 'Off';
end
S.ParPort = ParPort;
S.ParPortMessages = Common.PrepareParPort;
handles.ParPort    = ParPort;


%% GUI : Check if Eyelink toolbox is available

switch get(get(handles.uipanel_EyelinkMode,'SelectedObject'),'Tag')
    
    case 'radiobutton_EyelinkOff'
        
        EyelinkMode = 'Off';
        
    case 'radiobutton_EyelinkOn'
        
        EyelinkMode = 'On';
        
        % 'Eyelink.m' exists ?
        status = which('Eyelink.m');
        if isempty(status)
            error('FORTE:EyelinkToolbox','no ''Eyelink.m'' detected in the path')
        end
        
        % Save mode ?
        if strcmp(S.SaveMode,'NoSave')
            error('FORTE:SaveModeForEyelink',' \n ---> Save mode should be turned on when using Eyelink <--- \n ')
        end
        
        % Eyelink connected ?
        Eyelink.IsConnected
        
        eyelink_max_finename = 8;
        str = ['a':'z' 'A':'Z' '0':'9'];
        ln_str = length(str);
        
        name_num = randi(ln_str,[1 eyelink_max_finename]);
        name_str = str(name_num);
        
        S.EyelinkFile = name_str;
        
    otherwise
        
        warning('FORTE:EyelinkMode','Error in Eyelink mode')
        
end

S.EyelinkMode = EyelinkMode;


%% MAIN : Security : NEVER overwrite a file
% If erasing a file is needed, we need to do it manually

if strcmp(SaveMode,'SaveData') && strcmp(OperationMode,'Acquisition')
    
    if exist([DataFile '.mat'], 'file')
        error('MATLAB:FileAlreadyExists',' \n ---> \n The file %s.mat already exists .  <--- \n \n',DataFile);
    end
    
end


%% MAIN : Get stimulation parameters

S.Parameters = GetParameters;

% Screen mode selection
AvalableDisplays = get(handles.listbox_Screens,'String');
SelectedDisplay = get(handles.listbox_Screens,'Value');
S.ScreenID = str2double( AvalableDisplays(SelectedDisplay) );


%% GUI : Windowed screen ?

switch get(handles.checkbox_WindowedScreen,'Value')
    
    case 1
        WindowedMode = 'On';
    case 0
        WindowedMode = 'Off';
    otherwise
        warning('FORTE:WindowedScreen','Error in WindowedScreen')
        
end

S.WindowedMode = WindowedMode;


%% MAIN : Open PTB window & sound

S.PTB = StartPTB;


%% MAIN : Task run

EchoStart(Task)

switch Task
    
    case 'FORTE_implicit'
        TaskData = FORTE.Task('implicit');
        
    case 'FORTE_explicit'
        TaskData = FORTE.Task('explicit');
        
    case 'FORTE_forced_choice'
        TaskData = FORTE.Task('forced_choice');
        
    case 'EyelinkCalibration'
        Eyelink.Calibration(S.PTB.wPtr);
        TaskData.ER.Data = {};
        
    otherwise
        error('FORTE:Task','Task ?')
end

EchoStop(Task)

S.TaskData = TaskData;


%% MAIN : Save files on the fly : just a security in case of crash of the end the script

save(fullfile(fileparts(pwd),'data','LastS.mat'),'S');


%% MAIN : Close PTB

sca;
Priority( 0 );


%% MAIN : SPM data organization

[ names , onsets , durations ] = SPMnod;


%% MAIN : Saving data strucure

if strcmp(SaveMode,'SaveData') && strcmp(OperationMode,'Acquisition')
    
    if ~exist(DataPath, 'dir')
        mkdir(DataPath);
    end
    
    save(DataFile,     'S', 'names', 'onsets', 'durations');
    save([DataFile '_SPM'], 'names', 'onsets', 'durations');
    
    fprintf('full datafile saved : %s \n', DataFile)
    
    writetable(S.TaskData.behaviour,[DataFile '.csv'],'Delimiter', ';');
    writetable(S.TaskData.behaviour,[DataFile '.txt'],'Delimiter','\t');
    movefile([DataFile '.txt'], [DataFile '.tsv']); % stupide matlab that does not allow me to write the extension of my choice...
    
end


%% MAIN : Send S and SPM nod to workspace

assignin('base', 'S'        , S        );
assignin('base', 'names'    , names    );
assignin('base', 'onsets'   , onsets   );
assignin('base', 'durations', durations);


%% MAIN : End recording of Eyelink

% Eyelink mode 'On' ?
if strcmp(S.EyelinkMode,'On')
    
    % Stop recording and retrieve the file
    Eyelink.StopRecording( S.EyelinkFile )
    
end


%% MAIN + GUI : Ready for another run

set(handles.text_LastFileNameAnnouncer, 'Visible','on'                             )
set(handles.text_LastFileName         , 'Visible','on'                             )
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if ~strcmp( Task, 'FORTE_forced_choice' )
    set(handles.text_LastFileName         , 'String' , DataFile(length(DataPath)+1:end))
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

WaitSecs(0.100);
pause(0.100);
fprintf('\n')
fprintf('~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ \n')
fprintf('  Ready for another session   \n')
fprintf('~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ \n')


end % function
