function inside = IsInside( Cursor, Rect )

[x,y] = RectCenter(Rect);

distance = sqrt( (Cursor.Xptb-x).^2 + (Cursor.Yptb-y).^2 );

if size(Rect,1) == 1
    rect_diameter = Rect(3)-Rect(1);
else
    rect_diameter = Rect(3,1)-Rect(1,1);
end

inside = distance < (rect_diameter - Cursor.diameter)/2;

end % function
