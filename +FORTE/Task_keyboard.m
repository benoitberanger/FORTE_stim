function [ TaskData ] = Task_keyboard( task_version )
global S

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
    
    % [ ER, RR, KL, SR ] = Common.PrepareRecorders( EP );
    [ ER, RR, KL, SR, BR ] = Common.PrepareRecorders( EP, Parameters, task_version );
    
    % This is a pointer copy, not a deep copy
    S.EP = EP;
    S.ER = ER;
    S.RR = KL;
    S.BR = BR;
    % S.SR = SR;
    
    
    %% Prepare objects
    
    FIXATION    = FORTE.Prepare.Fixation();
    INSTRUCTION = FORTE.Prepare.Instruction( FIXATION );
    OUTCOME     = FORTE.Prepare.Outcome( task_version );
    if S.with_sound
        CASH_SOUND  = FORTE.Prepare.Cash();
        WHITE_NOISE = FORTE.Prepare.WhiteNoise( CASH_SOUND );
    end
    
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
                
                FIXATION.Draw();
                
                onset_fixation = Screen('Flip', S.PTB.wPtr);
                
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
                    
                end % while
                if EXIT
                    break
                end
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                
                
            case 'Instruction' % ------------------------------------------
                
                FIXATION.Draw();
                
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
                
                
                INSTRUCTION.Draw( triplet );
                
                onset_instruction = Screen('Flip', S.PTB.wPtr);
                ER.AddEvent({EP.Data{evt,1} onset_instruction-StartTime [] EP.Data{evt,4:end}});
                
                
            case 'Response' % ---------------------------------------------
                
                n_good_press = 1;
                keys_to_press = find(triplet);
                target_key = keys_to_press(n_good_press);
                valid_reward = -1; % flag : -1 oot-of-time, 0 bad, 1 good
                last_good_key_onset = 0;
                
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
                        
                        % Select only the response keys
                        is_response_key_being_presed = keyCode(S.Parameters.Fingers.Vect);
                        
                        % Disable last good key press for a few milliseconds, to avoid double input
                        if secs - last_good_key_onset < Parameters.DisableLastGoodKey
                            is_response_key_being_presed(keys_to_press(n_good_press-1)) = 0;
                        end
                        
                        if any(is_response_key_being_presed)
                            
                            response_key_being_presed = find(is_response_key_being_presed);
                            is_good_key = sum(response_key_being_presed == target_key);
                            
                            if is_good_key % Good
                                
                                switch n_good_press
                                    case 1
                                        onset_key_1 = secs;
                                    case 2
                                        onset_key_2 = secs;
                                    case 3
                                        onset_key_3 = secs;
                                end
                                
                                n_good_press = n_good_press+1;
                                if n_good_press > 3 % its a triplet
                                    valid_reward = 1;
                                    break
                                end
                                target_key = keys_to_press(n_good_press);
                                last_good_key_onset = secs;
                                
                            else % Bad
                                
                                valid_reward = 0;
                                break
                                
                            end
                            
                        end
                        
                        
                    end
                    
                end % while
                if EXIT
                    break
                end
                %==========================================================
                
            case 'Outcome' %-----------------------------------------------
                
                is_good = 0;
                is_bad  = 0;
                is_max  = 0;
                
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
                
                onset_outcome = Screen('Flip', S.PTB.wPtr);
                
                BR.AddEvent({nTot block trial triplet reward totalmaxreward OUTCOME.total.value is_good is_bad is_max ...
                    onset_fixation-StartTime onset_instruction-StartTime onset_key_1-StartTime onset_key_2-StartTime onset_key_3-StartTime onset_outcome-StartTime});
                
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
                    
                    % SR.AddSample([secs-StartTime 0 0])
                    
                    % Fetch keys
                    [keyIsDown, secs, keyCode] = KbCheck;
                    
                    if keyIsDown
                        % ~~~ ESCAPE key ? ~~~
                        [ EXIT, StopTime ] = Common.Interrupt( keyCode, ER, RR, StartTime );
                        if EXIT
                            break
                        end
                    end
                    
                end % while
                if EXIT
                    break
                end
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                
                
            case 'ForcedChoice' %------------------------------------------
                
                is_good = 0;
                is_bad  = 0;
                is_max  = 0;
                
                FIXATION.Draw();
                INSTRUCTION.Draw( triplet );
                OUTCOME.high_reward.Draw();
                OUTCOME.low_reward.Draw();
                
                onset_forcedchoice = Screen('Flip', S.PTB.wPtr);
                ER.AddEvent({EP.Data{evt,1} onset_forcedchoice-StartTime [] EP.Data{evt,4:end}});
                
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
                    nMax , round(100*nMax /nTot)...
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
