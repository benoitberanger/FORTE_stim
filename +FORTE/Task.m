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
    EXIT = 0;
    
    % Loop over the EventPlanning
    for evt = 1 : size( EP.Data , 1 )
        
        Common.CommandWindowDisplay( EP, evt );
        
        switch EP.Data{evt,1}
            
            case 'StartTime' % --------------------------------------------
                
                StartTime = Common.StartTimeEvent;
                lastFlipOnset = StartTime;
                
            case 'StopTime' % ---------------------------------------------
                
                [ ER, RR, StopTime ] = Common.StopTimeEvent( EP, ER, RR, StartTime, evt );
                
                
            case 'Fixation' % ---------------------------------------------
                
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
                
                triplet = EP.Data{evt,4};
                reward  = EP.Data{evt,5};
                fprintf('[%s] %s \n', num2str(triplet), reward)
                INSTRUCTION.Draw( triplet );
                
                lastFlipOnset = Screen('Flip', S.PTB.wPtr);
                ER.AddEvent({EP.Data{evt,1} lastFlipOnset-StartTime [] EP.Data{evt,4:end}});
                
                
            case 'Response' % ---------------------------------------------
                
                n_good_press = 1;
                keys_to_press = find(triplet);
                next_key = keys_to_press(n_good_press);
                valid_reward = -1;
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
                        
                        is_response_key_being_presed = keyCode(S.Parameters.Fingers.Vect);
                        if secs - last_good_key_onset < Parameters.DisableLastGoodKey
                            is_response_key_being_presed(keys_to_press(n_good_press-1)) = 0;
                        end
                        
                        if any(is_response_key_being_presed)
                            
                            good_key_being_presed = find(is_response_key_being_presed);
                            is_next_key = sum(good_key_being_presed == next_key);
                            
                            if is_next_key
                                
                                fprintf('good \n')
                                
                                n_good_press = n_good_press+1;
                                if n_good_press > 3
                                    valid_reward = 1;
                                    break
                                end
                                next_key = keys_to_press(n_good_press);
                                last_good_key_onset = secs;
                                
                            else
                                
                                fprintf('bad \n')
                                valid_reward = 0;
                                break
                                
                            end
                            
                        end

                        
                    end
                    
                end % while
                if EXIT
                    break
                end
                if secs>when
                    fprintf('!!! MaxTime reached !!! \n');
                end
                %==========================================================
                
            case 'Outcome'
                
                switch valid_reward
                    case 1 % good
                        OUTCOME.Draw(reward)
                    case 0 % bad
                        OUTCOME.Draw('')
                    case -1 % out of time
                        OUTCOME.Draw('')
                end
                    
                
                
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
