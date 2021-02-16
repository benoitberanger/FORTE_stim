function [ fixation ] = Fixation
global S

fixation = Fixation( ...
    [S.PTB.CenterH S.PTB.CenterV] , ...
    S.Parameters.Forte.Fixation.spacing_x_ratio , ...
    S.Parameters.Forte.Fixation.spacing_y_ratio , ...
    S.Parameters.Forte.Fixation.dimension_ratio , ...
    S.Parameters.Forte.Fixation.width_height_ratio,...
    S.Parameters.Forte.Fixation.color );

fixation.LinkToWindowPtr( S.PTB.wPtr )

fixation.AssertReady % just to check

end % function