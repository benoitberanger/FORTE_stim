function [ TaskData ] = Task_motor( task_version )
global S newX newY

S.PTB.slack = 0.001;

try
    %% Tunning of the task
    
    switch task_version
        case {'implicit', 'explicit'}
            [ EP, Parameters ] = FORTE.Planning_im_ex_plicit;
        case 'forced_choice'
            [ EP, Parameters ] = FORTE.Planning_forced_choice;
    end
    TaskData.Parameters = Parameters;
    
    % End of preparations
    EP.BuildGraph;
    TaskData.EP = EP;
    
    
    %% Prepare event record and keybinf logger
    
    [ ER, RR, KL, SR, BR ] = Common.PrepareRecorders( EP, Parameters, task_version );
    
    % This is a pointer copy, not a deep copy
    S.EP = EP;
    S.ER = ER;
    S.RR = KL;
    S.BR = BR;
    S.SR = SR;
    
    
    %% Prepare objects
    
    OUTCOME         = FORTE.Prepare.Outcome( task_version );
    if S.with_sound
        CASH_SOUND  = FORTE.Prepare.Cash();
        WHITE_NOISE = FORTE.Prepare.WhiteNoise( CASH_SOUND );
    end
    Cross           = FORTE.Prepare.Cross         ;
    BigCircle       = FORTE.Prepare.BigCircle     ;
    TargetCenter    = FORTE.Prepare.TargetCenter  ;
    Cursor          = FORTE.Prepare.Cursor        ;
    TargetFixation  = FORTE.Prepare.TargetFixation;
    
    
    %% Eyelink
    
    Common.StartRecordingEyelink;
    
    
    %% Go
    
    % Initialize some variables
    EXIT  = 0;
    nGood = 0;
    nBad  = 0;
    nMax  = 0;
    nTot  = 0;
    
    % Loop over the EventPlanning
    for evt = 1 : size( EP.Data , 1 )
        
        switch EP.Data{evt,1}
            
            case 'StartTime' % --------------------------------------------
                
                % Fetch initialization data
                switch S.InputMethod
                    case 'Joystick'
                        [newX, newY] = FORTE.QueryJoystickData( Cursor.screenX, Cursor.screenY );
                    case 'Mouse'
                        SetMouse(Cursor.Xptb,Cursor.Yptb,Cursor.wPtr);
                        [newX, newY] = FORTE.QueryMouseData( Cursor.wPtr, Cursor.Xorigin, Cursor.Yorigin, Cursor.screenY );
                end
                
                % Here at initialization, we don't apply deviation, just fetche raw data
                Cursor.Move(newX,newY);
                
                BigCircle.Draw();
                Cross.Draw();
                
                StartTime = Common.StartTimeEvent;
                
                
            case 'StopTime' % ---------------------------------------------
                
                [ ER, RR, StopTime ] = Common.StopTimeEvent( EP, ER, RR, StartTime, evt );
                
                
            case 'Fixation' % ---------------------------------------------
                
                triplet        = EP.Data{evt,4};
                reward         = EP.Data{evt,5};
                block          = EP.Data{evt,6};
                trial          = EP.Data{evt,7};
                totalmaxreward = EP.Data{evt,8};
                
                
                % log
                switch task_version
                    case {'implicit', 'explicit'}
                        fprintf('block=%2.d/%2.d   trial=%2.d/10   [%s]   %4s   ',...
                            block, Parameters.nBlock, trial, num2str(triplet), reward)
                    case 'forced_choice'
                        fprintf('[%s]   %4s   ',...
                            num2str(triplet), reward)
                end
                
                BigCircle.Draw();
                Cross.Draw();
                TargetFixation.frameCurrentColor = TargetFixation.frameBaseColor;
                TargetFixation.Draw();
                Cursor.Update(S.InputMethod);
                
                onset_fixation = Screen('Flip', S.PTB.wPtr);
                SR.AddSample([onset_fixation-StartTime Cursor.X Cursor.Y Cursor.R Cursor.Theta])
                
                ER.AddEvent({EP.Data{evt,1} onset_fixation-StartTime [] EP.Data{evt,4:end}});
                %RR.AddEvent({[EP.Data{evt,1} '_CROSS'] lastFlipOnset-StartTime [] []});
                
                when = onset_fixation + EP.Data{evt,3} - S.PTB.slack;
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                secs = onset_fixation;
                while secs < when
                    
                    % Fetch keys
                    [keyIsDown, secs, keyCode] = KbCheck;
                    if keyIsDown
                        % ~~~ ESCAPE key ? ~~~
                        [ EXIT, StopTime ] = Common.Interrupt( keyCode, ER, RR, StartTime );
                        if EXIT
                            break
                        end
                    end
                    
                    BigCircle.Draw();
                    Cross.Draw();
                    TargetFixation.Draw();
                    Cursor.Update(S.InputMethod);
                    last_flip_onset = Screen('Flip', S.PTB.wPtr);
                    SR.AddSample([last_flip_onset-StartTime Cursor.X Cursor.Y Cursor.R Cursor.Theta])
                
                end % while
                if EXIT
                    break
                end
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                
                
            case 'Instruction' % ------------------------------------------
                
                BigCircle.Draw();
                Cross.Draw();
                TargetFixation.frameCurrentColor(:,logical(triplet)) = repmat( S.Parameters.Forte.Instruction.color', [1 3] );
                TargetFixation.Draw();
                
                switch task_version
                    case 'implicit'
                        % pass, don't show the reward
                    case 'explicit'
                        % show the reward
                        switch reward
                            case 'high'
                                OUTCOME.high_reward.Draw();
                            case 'low'
                                OUTCOME.low_reward.Draw();
                        end
                    otherwise
                        error('something went wring with workflow if task_version=%s', task_version)
                end
                
                Cursor.Update(S.InputMethod);
                onset_instruction = Screen('Flip', S.PTB.wPtr);
                ER.AddEvent({EP.Data{evt,1} onset_instruction-StartTime [] EP.Data{evt,4:end}});
                SR.AddSample([onset_instruction-StartTime Cursor.X Cursor.Y Cursor.R Cursor.Theta])
                
                
            case 'Response' % ---------------------------------------------
                
                n_good_target = 1;
                target_list = find(triplet);
                next_target = target_list(n_good_target);
                valid_reward = -1; % flag : -1 out-of-time, 0 bad, 1 good
                last_good_target_onset = 0;
                
                has_left_center = 0;
                has_left_target = 0;
                goto_center = 0;
                goto_target = 1;
                last_goback = 0;
                
                onset_key_1 = NaN;
                onset_key_2 = NaN;
                onset_key_3 = NaN;
                
                ER.AddEvent({EP.Data{evt,1} onset_instruction-StartTime [] EP.Data{evt,4:end}});
                
                when = onset_instruction + Parameters.MaxTime - S.PTB.slack;
                %==========================================================
                secs = onset_instruction;
                while secs < when
                    
                    % Fetch keys
                    [keyIsDown, secs, keyCode] = KbCheck;
                    if keyIsDown
                        % ~~~ ESCAPE key ? ~~~
                        [ EXIT, StopTime ] = Common.Interrupt( keyCode, ER, RR, StartTime );
                        if EXIT
                            break
                        end
                    end
                    
                    % Update next key & colors
                    is_in_center = FORTE.IsInside(Cursor, TargetCenter.  Rect);
                    is_in_target = FORTE.IsInside(Cursor, TargetFixation.Rect);
                    
                    
                    if goto_target
                        
                        if ~has_left_center
                            if is_in_center
                                TargetCenter.Draw();
                            else
                                has_left_center = 1;
                                Cross.Draw();
                            end
                            
                        else
                            Cross.Draw();
                            
                            if any(is_in_target)
                                target_reached = find(is_in_target);
                                is_good_target = sum(target_reached == next_target);
                                
                                if is_good_target % Good
                                    
                                    switch n_good_target
                                        case 1
                                            onset_key_1 = secs;
                                        case 2
                                            onset_key_2 = secs;
                                        case 3
                                            onset_key_3 = secs;
                                    end
                                    
                                    TargetFixation.frameCurrentColor(:,next_target) = TargetFixation.frameBaseColor(:,next_target);
                                    n_good_target = n_good_target+1;
                                    if n_good_target <= 3
                                        next_target = target_list(n_good_target);
                                    else % its a triplet
                                        valid_reward = 1;
                                        last_goback = 1;                                        
                                    end
                                    
                                    last_good_target_onset = secs;
                                    
                                else % Bad
                                    
                                    valid_reward = 0;
                                    last_goback = 1;
                                    
                                end % good_target
                                
                                goto_target = 0;
                                goto_center = 1;
                                
                            end % any target ?
                            
                        end % traveling OUT
                        
                    end % objective : reach target
                    
                    if goto_center
                        
                        if is_in_center
                            goto_target = 1;
                            goto_center = 0;
                            if last_goback
                                break
                            end
                            
                        else
                            TargetCenter.Draw();
                            
                        end
                        
                    end % objective : reach center
                    
                    BigCircle.Draw();
                    TargetFixation.Draw();
                    
                    switch task_version
                        case 'implicit'
                            % pass, don't show the reward
                        case 'explicit'
                            % show the reward
                            switch reward
                                case 'high'
                                    OUTCOME.high_reward.Draw();
                                case 'low'
                                    OUTCOME.low_reward.Draw();
                            end
                        otherwise
                            error('something went wring with workflow if task_version=%s', task_version)
                    end
                    
                    Cursor.Update(S.InputMethod);
                    Cursor.Draw();
                    
                    Screen('DrawingFinished',S.PTB.wPtr);
                    last_flip_onset = Screen('Flip', S.PTB.wPtr);
                    SR.AddSample([last_flip_onset-StartTime Cursor.X Cursor.Y Cursor.R Cursor.Theta])
                    
                    
                end % while
                if EXIT
                    break
                end
                %==========================================================
                
            case 'Outcome' %-----------------------------------------------
                
                is_good = 0;
                is_bad  = 0;
                is_max  = 0;
                
                Cross.Draw();
                
                switch valid_reward
                    case 1 % good
                        
                        switch reward
                            case 'high'
                                OUTCOME.high_reward.Draw();
                                OUTCOME.total.value = OUTCOME.total.value + 10.00;
                            case 'low'
                                OUTCOME.low_reward.Draw();
                                OUTCOME.total.value = OUTCOME.total.value + 00.01;
                        end
                        
                        is_good = 1;
                        nGood = nGood + 1;
                        logmsg = '';
                        OUTCOME.Draw();
                        if S.with_sound, CASH_SOUND.Playback(); end
                        
                    case 0 % bad
                        
                        is_bad  = 1;
                        nBad = nBad+ 1;
                        logmsg = 'bad';
                        OUTCOME.Draw();
                        if S.with_sound, WHITE_NOISE.Playback(); end
                        
                    case -1 % out of time
                        
                        is_max  = 1;
                        nMax = nMax + 1;
                        logmsg = '!!! MaxTime reached !!!';
                        OUTCOME.Draw();
                        if S.with_sound, WHITE_NOISE.Playback(); end
                        
                end
                nTot = nTot + 1;
                
                Cursor.Update(S.InputMethod);
                onset_outcome = Screen('Flip', S.PTB.wPtr);
                BR.AddEvent({nTot block trial triplet reward totalmaxreward OUTCOME.total.value is_good is_bad is_max ...
                    onset_fixation-StartTime onset_instruction-StartTime onset_key_1-StartTime onset_key_2-StartTime onset_key_3-StartTime onset_outcome-StartTime});
                SR.AddSample([onset_outcome-StartTime Cursor.X Cursor.Y Cursor.R Cursor.Theta])
                
                % log
                gain_pct = round( 100*OUTCOME.total.value/totalmaxreward );
                loss_pct = 100 - gain_pct;
                fprintf('T=%6.2f   t=%6.2f   gains/losses=%3d%%/%3d%%   G=%3d-%3d%%   B=%3d-%3d%%   M=%3d-%3d%%   %s \n',...
                    totalmaxreward, OUTCOME.total.value,...
                    gain_pct, loss_pct, ...
                    nGood, round(100*nGood/nTot),...
                    nBad , round(100*nBad /nTot),...
                    nMax , round(100*nMax /nTot),...
                    logmsg)
                
                ER.AddEvent({EP.Data{evt,1} onset_outcome-StartTime [] EP.Data{evt,4:end}});
                %RR.AddEvent({[EP.Data{evt,1} '_CROSS'] lastFlipOnset-StartTime [] []});
                
                when = onset_outcome + EP.Data{evt,3} - S.PTB.slack;
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                secs = onset_outcome;
                while secs < when    
                    
                    % Fetch keys
                    [keyIsDown, secs, keyCode] = KbCheck;
                    if keyIsDown
                        % ~~~ ESCAPE key ? ~~~
                        [ EXIT, StopTime ] = Common.Interrupt( keyCode, ER, RR, StartTime );
                        if EXIT
                            break
                        end
                    end
                    
                    Cross.Draw();
                    
                    switch valid_reward
                        case 1 % good
                            switch reward
                                case 'high'
                                    OUTCOME.high_reward.Draw();
                                case 'low'
                                    OUTCOME.low_reward.Draw();
                            end
                    end
                    OUTCOME.Draw();
                    
                    Cursor.Update(S.InputMethod);
                    last_flip_onset = Screen('Flip', S.PTB.wPtr);
                    SR.AddSample([last_flip_onset-StartTime Cursor.X Cursor.Y Cursor.R Cursor.Theta])
                    
                end % while
                if EXIT
                    break
                end
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                
                
            case 'ForcedChoice' %------------------------------------------
                
                is_good = 0;
                is_bad  = 0;
                is_max  = 0;
                
                BigCircle.Draw();
                Cross.Draw();
                TargetFixation.frameCurrentColor                     = TargetFixation.frameBaseColor;
                TargetFixation.frameCurrentColor(:,logical(triplet)) = repmat( S.Parameters.Forte.Instruction.color', [1 3] );
                TargetFixation.Draw();
                
                OUTCOME.high_reward.Draw();
                OUTCOME.low_reward.Draw();
                
                Cursor.Update(S.InputMethod);
                onset_forcedchoice = Screen('Flip', S.PTB.wPtr);
                ER.AddEvent({EP.Data{evt,1} onset_forcedchoice-StartTime [] EP.Data{evt,4:end}});
                SR.AddSample([onset_forcedchoice-StartTime Cursor.X Cursor.Y Cursor.R Cursor.Theta])
                
                when = onset_forcedchoice + Parameters.MaxTime - S.PTB.slack;
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                secs = onset_forcedchoice;
                while secs < when
                    
                    % SR.AddSample([secs-StartTime 0 0])
                    
                    % Fetch keys
                    [keyIsDown, secs, keyCode] = KbCheck;
                    
                    if keyIsDown
                        % ~~~ ESCAPE key ? ~~~
                        [ EXIT, StopTime ] = Common.Interrupt( keyCode, ER, RR, StartTime );
                        if EXIT
                            break
                        end
                        
                        if     keyCode(S.Parameters.Fingers.Vect(  1))
                            switch reward
                                case 'high'
                                    is_good = 1;
                                    nGood = nGood + 1;
                                    break
                                case 'low'
                                    is_bad  = 1;
                                    nBad = nBad + 1;
                                    break
                            end
                            
                        elseif keyCode(S.Parameters.Fingers.Vect(end))
                            switch reward
                                case 'high'
                                    is_bad  = 1;
                                    nBad = nBad + 1;
                                    break
                                case 'low'
                                    is_good = 1;
                                    nGood = nGood + 1;
                                    break
                            end
                            
                        end
                        
                    end
                    
                    Cross.Draw();
                    TargetFixation.Draw();
                    OUTCOME.high_reward.Draw();
                    OUTCOME.low_reward.Draw();
                    Cursor.Update(S.InputMethod);
                    last_flip_onset = Screen('Flip', S.PTB.wPtr);
                    SR.AddSample([last_flip_onset-StartTime Cursor.X Cursor.Y Cursor.R Cursor.Theta])

                end % while
                if EXIT
                    break
                end
                
                if secs >= when
                    is_max = 1;
                    nMax = nMax + 1;
                end
                nTot = nTot + 1;
                
                BR.AddEvent({nTot triplet reward  is_good is_bad is_max ...
                    onset_fixation-StartTime onset_forcedchoice-StartTime secs-StartTime });
                
                % log
                fprintf(' G=%3d-%3d%%   B=%3d-%3d%%   M=%3d-%3d%%   \n',...
                    nGood, round(100*nGood/nTot),...
                    nBad , round(100*nBad /nTot),...
                    nMax , round(100*nMax /nTot) ...
                    )
                
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                
            otherwise % ---------------------------------------------------
                
                error('unknown envent')
                
        end % switch
        
        % This flag comes from Common.Interrupt, if ESCAPE is pressed
        if EXIT
            break
        end
        
    end % for
    
    
    %% End of stimulation
    
    % Close the audio device
    if S.with_sound
        PsychPortAudio('Close');
    end
    
    TaskData = Common.EndOfStimulation( TaskData, EP, ER, RR, KL, SR, BR, StartTime, StopTime );
    
    TaskData.behaviour = cell2table( TaskData.BR.Data, 'VariableNames', TaskData.BR.Header, 'RowNames', cellstr(num2str( cell2mat( TaskData.BR.Data(:,1) ) )));
    TaskData.behaviour.triplet = num2str(TaskData.behaviour.triplet);
    assignin('base','behaviour',TaskData.behaviour)
    disp(TaskData.behaviour)
    
    
catch err
    
    Common.Catch( err );
    
end

end % function
