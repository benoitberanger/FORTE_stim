function [ bigcircle ] = BigCircle
global S

diameter   = S.Parameters.Forte.Circle.DimensionRatio*S.PTB.wRect(4);
thickness  = S.Parameters.Forte.Circle.WidthRatio*diameter;
frameColor = S.Parameters.Forte.Circle.FrameColor;
diskColor  = S.Parameters.Forte.Circle.DiskColor;
valueColor = S.Parameters.Forte.Circle.ValueColor;
Xorigin    = S.PTB.CenterH;
Yorigin    = S.PTB.CenterV;
screenX    = S.PTB.wRect(3);
screenY    = S.PTB.wRect(4);

bigcircle = Circle(...
    diameter   ,...     % diameter  in pixels
    thickness  ,...     % thickness in pixels
    frameColor ,...     % frame color [R G B] 0-255
    diskColor  ,...     % disk  color [R G B] 0-255
    valueColor ,...     % disk  color [R G B] 0-255
    Xorigin    ,...     % X origin  in pixels
    Yorigin    ,...     % Y origin  in pixels
    screenX    ,...     % H pixels of the screen
    screenY    );       % V pixels of the screen

bigcircle.filled = 0; % only draw the frame, dont fill the disk inside

bigcircle.LinkToWindowPtr( S.PTB.wPtr )

bigcircle.AssertReady % just to check

end % function
