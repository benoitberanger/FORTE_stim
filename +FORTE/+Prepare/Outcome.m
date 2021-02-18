function [ outcome ] = Outcome( )
global S

outcome = Outcome( ...
    fullfile(pwd,'img',S.Parameters.Forte.Outcome.fname_10euro),...
    fullfile(pwd,'img',S.Parameters.Forte.Outcome.fname_1cent),...
    S.Parameters.Forte.Outcome.dimension_ratio,...
    [S.PTB.CenterH S.PTB.CenterV],...
    S.Parameters.Forte.Outcome.font_color,...
    S.Parameters.Forte.Outcome.font_size_ratio...
    );

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
outcome.high_reward.Move([outcome.screen_center_px(1) outcome.screen_center_px(2)*2*S.Parameters.Forte.Outcome.y_offcet_ratio_img]);
outcome.low_reward. Move([outcome.screen_center_px(1) outcome.screen_center_px(2)*2*S.Parameters.Forte.Outcome.y_offcet_ratio_img]);

outcome.total.LinkToWindowPtr( S.PTB.wPtr );
outcome.total.Yptb = S.PTB.wRect(4) * S.Parameters.Forte.Outcome.y_offcet_ratio_txt;
outcome.total.GenRect();

outcome.AssertReady % just to check

end % function