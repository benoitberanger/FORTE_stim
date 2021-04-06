function [ targetfixation ] = TargetFixation
global S

diameter   = S.Parameters.Forte.Target.DimensionRatio*S.PTB.wRect(4);
thickness  = S.Parameters.Forte.Target.WidthRatio*diameter;
frameColor = S.Parameters.Forte.Target.FrameColor;
diskColor  = S.Parameters.Forte.Target.DiskColor;
valueColor = S.Parameters.Forte.Target.ValueColor;
Xorigin    = S.PTB.CenterH;
Yorigin    = S.PTB.CenterV;
screenX    = S.PTB.wRect(3);
screenY    = S.PTB.wRect(4);
R          = S.Parameters.Forte.Circle.DimensionRatio/2*S.PTB.wRect(4);
R          = repmat(R, [1 numel(S.Parameters.Forte.Target.Angle)]);
THETA      = S.Parameters.Forte.Target.Angle;

targetfixation = MultiCircle(...
    diameter   ,...     % diameter  in pixels
    thickness  ,...     % thickness in pixels
    frameColor ,...     % frame color [R G B] 0-255
    diskColor  ,...     % disk  color [R G B] 0-255
    valueColor ,...     % disk  color [R G B] 0-255
    Xorigin    ,...     % X origin  in pixels
    Yorigin    ,...     % Y origin  in pixels
    screenX    ,...     % H pixels of the screen
    screenY    ,...     % V pixels of the screen
    R          ,...
    THETA       ...
    );      

targetfixation.LinkToWindowPtr( S.PTB.wPtr )

targetfixation.AssertReady % just to check

end % function
