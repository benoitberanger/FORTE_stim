function Draw( obj, vect )

if nargin < 2
    vect = [1 1 1 1 1];
end
vect = logical(vect);

obj.AssertReady

Screen('FrameOval', obj.wPtr, obj.color, obj.all_rects(:,vect), obj.pen_width);

end % function
