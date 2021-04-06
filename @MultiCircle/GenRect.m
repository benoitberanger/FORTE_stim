function GenRect( obj )

% In local canonical space, with Xorigin Yorigin as center
X = obj.R .* cos(obj.THETA *pi/180);
Y = obj.R .* sin(obj.THETA *pi/180);

obj.Xptb =  X + obj.Xorigin               ;
obj.Yptb = -Y - obj.Yorigin + obj.screenY ;

baseRect = [0 0 obj.diameter obj.diameter];
for i = 1 : numel(X)
    obj.Rect(:,i) = CenterRectOnPoint(baseRect, obj.Xptb(i), obj.Yptb(i))';
end

end % function
