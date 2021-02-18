function GenerateCoords( obj )

% Fetch some useful values
x_pos = obj.x_pos;
y_pos = obj.y_pos;
yc = obj.screen_center_px(2);

sz = yc * obj.diameter_ratio;
base_rect = [0 0 sz sz];

for i = 1 : 5
    obj.all_rects(:,i) = CenterRectOnPoint( base_rect, x_pos(i), y_pos(i) )';
end

obj.pen_width = sz * obj.thickness_ratio;

end
