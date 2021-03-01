function GenerateCoords( obj )

xs = obj.screen_size_px(1);
ys = obj.screen_size_px(2);   % screen height is my unit of measure, it's the unitary dimension = 1.0
xf = obj.fixation_center_px(1);
yf = obj.fixation_center_px(2);

x_pos = [xf xf xf xf xf] +  [-2 -1  0 +1 +2] * ys * obj.spacing_x_ratio;
y_pos = [yf yf yf yf yf] + -[-1  0 +1  0 -1] * ys * obj.spacing_y_ratio;
obj.x_pos = x_pos;
obj.y_pos = y_pos;

sz = ys * obj.dimension_ratio;
r  = obj.width_height_ratio;

base_rect_x = [0 0 sz   sz*r];
base_rect_y = [0 0 sz*r sz  ];

all_rects = obj.all_rects;

c = 0;
for i = 1 : 5
    c = c + 1;
    all_rects(:,c) = CenterRectOnPoint( base_rect_x, x_pos(i), y_pos(i))';
    c = c + 1;
    all_rects(:,c) = CenterRectOnPoint( base_rect_y, x_pos(i), y_pos(i))';
end

obj.all_rects = all_rects;

end
