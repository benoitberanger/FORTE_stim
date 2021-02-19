function [ TaskData ] = Task
global S

S.PTB.slack = 0.001;

try
    %% Tunning of the task
    
    [ EP, Parameters ] = FORTE.Planning;
    TaskData.Parameters = Parameters;
    
    % End of preparations
    EP.BuildGraph;
    TaskData.EP = EP;
    
    
    %% Prepare event record and keybinf logger
    
    % [ ER, RR, KL, SR ] = Common.PrepareRecorders( EP );
    [ ER, RR, KL ] = Common.PrepareRecorders( EP );
    
    % This is a pointer copy, not a deep copy
    S.EP = EP;
    S.ER = ER;
    S.RR = KL;
    % S.SR = SR;
    
    
    %% Prepare objects
    
    FIXATION    = FORTE.Prepare.Fixation;
    INSTRUCTION = FORTE.Prepare.Instruction(FIXATION);
    OUTCOME     = FORTE.Prepare.Outcome;
    
    
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
                lastFlipOnset = StartTime;
                
            case 'StopTime' % ---------------------------------------------
                
                [ ER, RR, StopTime ] = Common.StopTimeEvent( EP, ER, RR, StartTime, evt );
                
                
            case 'Fixation' % ---------------------------------------------
                
                triplet        = EP.Data{evt,4};
                reward         = EP.Data{evt,5};
                block          = EP.Data{evt,6};
                trial          = EP.Data{evt,7};
                totalmaxreward = EP.Data{evt,8};
                
                % log
                fprintf('block=%2.d/%2.d   trial=%2.d/10   [%s]   %4s   ',...
                    block, Parameters.nBlock, trial, num2str(triplet), reward)
                
                FIXATION.Draw();
                
                lastFlipOnset = Screen('Flip', S.PTB.wPtr);
                
                ER.AddEvent({EP.Data{evt,1} lastFlipOnset-StartTime [] EP.Data{evt,4:end}});
                %RR.AddEvent({[EP.Data{evt,1} '_CROSS'] lastFlipOnset-StartTime [] []});
                
                when = lastFlipOnset + EP.Data{evt,3} - S.PTB.slack;
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                secs = lastFlipOnset;
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
                
                INSTRUCTION.Draw( triplet );
                
                lastFlipOnset = Screen('Flip', S.PTB.wPtr);
                ER.AddEvent({EP.Data{evt,1} lastFlipOnset-StartTime [] EP.Data{evt,4:end}});
                
                
            case 'Response' % ---------------------------------------------
                
                n_good_press = 1;
                keys_to_press = find(triplet);
                target_key = keys_to_press(n_good_press);
                valid_reward = -1; % flag : -1 oot-of-time, 0 bad, 1 good
                last_good_key_onset = 0;
                
                ER.AddEvent({EP.Data{evt,1} lastFlipOnset-StartTime [] EP.Data{evt,4:end}});
                
                when = lastFlipOnset + Parameters.MaxTime - S.PTB.slack;
                %==========================================================
                secs = lastFlipOnset;
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
                        
                        nGood = nGood + 1;
                        logmsg = '';
                        OUTCOME.Draw();
                        
                    case 0 % bad
                        
                        nBad = nBad+ 1;
                        logmsg = 'bad';
                        OUTCOME.Draw();
                        
                    case -1 % out of time
                        
                        nMax = nMax + 1;
                        logmsg = '!!! MaxTime reached !!!';
                        OUTCOME.Draw();
                        
                end
                nTot = nTot + 1;
                
                gain_pct = round( 100*OUTCOME.total.value/totalmaxreward );
                loss_pct = 100 - gain_pct;
                
                % log
                fprintf('T=%6.2f   t=%6.2f   gains/losses=%3d%%/%3d%%   G=%3d-%3d%%   B=%3d-%3d%%   M=%3d-%3d%%   %s \n',...
                    totalmaxreward, OUTCOME.total.value,...
                    gain_pct, loss_pct, ...
                    nGood, round(100*nGood/nTot),...
                    nBad , round(100*nBad /nTot),...
                    nMax , round(100*nMax /nTot),...
                    logmsg)
                
                
                lastFlipOnset = Screen('Flip', S.PTB.wPtr);
                
                ER.AddEvent({EP.Data{evt,1} lastFlipOnset-StartTime [] EP.Data{evt,4:end}});
                %RR.AddEvent({[EP.Data{evt,1} '_CROSS'] lastFlipOnset-StartTime [] []});
                
                when = lastFlipOnset + EP.Data{evt,3} - S.PTB.slack;
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                secs = lastFlipOnset;
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
    % PsychPortAudio('Close');
    
    % TaskData = Common.EndOfStimulation( TaskData, EP, ER, RR, KL, SR, StartTime, StopTime );
    TaskData = Common.EndOfStimulation( TaskData, EP, ER, RR, KL, StartTime, StopTime );
    
    % TaskData.BR = BR;
    % assignin('base','BR', BR)
    
    
catch err
    
    Common.Catch( err );
    
end

end % function
