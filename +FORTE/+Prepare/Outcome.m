function [ outcome ] = Outcome( task_version )
global S

is_keyboard = ~isempty(strfind(S.Task,'keyboard'));
is_motor    = ~isempty(strfind(S.Task,'motor'   )) | ~isempty(strfind(S.Task,'mouse')) | ~isempty(strfind(S.Task,'joystick'));

if is_keyboard

    outcome = Outcome( ...
        fullfile(pwd,'img',S.Parameters.Forte.Outcome.fname_10euro),...
        fullfile(pwd,'img',S.Parameters.Forte.Outcome.fname_1cent),...
        S.Parameters.Forte.Outcome.Keyboard.dimension_ratio,...
        [S.PTB.CenterH S.PTB.CenterV],...
        S.Parameters.Forte.Outcome.font_color,...
        S.Parameters.Forte.Outcome.font_size_ratio...
        );
    
elseif is_motor
    
    outcome = Outcome( ...
        fullfile(pwd,'img',S.Parameters.Forte.Outcome.fname_10euro),...
        fullfile(pwd,'img',S.Parameters.Forte.Outcome.fname_1cent),...
        S.Parameters.Forte.Outcome.Motor.dimension_ratio,...
        [S.PTB.CenterH S.PTB.CenterV],...
        S.Parameters.Forte.Outcome.font_color,...
        S.Parameters.Forte.Outcome.font_size_ratio...
        );
    
else
    
    error('???')

end

% Generate PTB texture
outcome.LinkToWindowPtr( S.PTB.wPtr )
outcome.high_reward.MakeTexture;
outcome.low_reward.MakeTexture;

% Rescale
scale = S.PTB.wRect(4)/outcome.high_reward.baseRect(4) * outcome.dimension_ratio;
outcome.high_reward.Rescale(scale);
scale = S.PTB.wRect(4)/outcome.low_reward.baseRect(4) * outcome.dimension_ratio;
outcome.low_reward.Rescale(scale);

% Move
if is_keyboard
    switch task_version
        case {'implicit', 'explicit'}
            outcome.high_reward.Move([outcome.screen_center_px(1) outcome.screen_center_px(2)*2*S.Parameters.Forte.Outcome.Keyboard.y_offcet_ratio_img]);
            outcome.low_reward. Move([outcome.screen_center_px(1) outcome.screen_center_px(2)*2*S.Parameters.Forte.Outcome.Keyboard.y_offcet_ratio_img]);
        case 'forced_choice'
            outcome.high_reward.Move([outcome.screen_center_px(1)*0.35 outcome.screen_center_px(2)*2*S.Parameters.Forte.Outcome.Keyboard.y_offcet_ratio_img]);
            outcome.low_reward. Move([outcome.screen_center_px(1)*1.60 outcome.screen_center_px(2)*2*S.Parameters.Forte.Outcome.Keyboard.y_offcet_ratio_img]);
    end
elseif is_motor
    switch task_version
        case {'implicit', 'explicit'}
            outcome.high_reward.Move([outcome.screen_center_px(1) outcome.screen_center_px(2)*2*S.Parameters.Forte.Outcome.Motor.y_offcet_ratio_img]);
            outcome.low_reward. Move([outcome.screen_center_px(1) outcome.screen_center_px(2)*2*S.Parameters.Forte.Outcome.Motor.y_offcet_ratio_img]);
        case 'forced_choice'
            outcome.high_reward.Move([outcome.screen_center_px(1)*0.3 outcome.screen_center_px(2)*2*S.Parameters.Forte.Outcome.Motor.y_offcet_ratio_img]);
            outcome.low_reward. Move([outcome.screen_center_px(1)*1.7 outcome.screen_center_px(2)*2*S.Parameters.Forte.Outcome.Motor.y_offcet_ratio_img]);
    end
end

outcome.total.LinkToWindowPtr( S.PTB.wPtr );
if is_keyboard
    outcome.total.Yptb = S.PTB.wRect(4) * S.Parameters.Forte.Outcome.Keyboard.y_offcet_ratio_txt;
elseif is_motor
    outcome.total.Yptb = S.PTB.wRect(4) * S.Parameters.Forte.Outcome.Motor   .y_offcet_ratio_txt;
end
outcome.total.GenRect();

outcome.AssertReady % just to check

end % function