function GenerateCoords( obj )

hRect = [0 0 obj.dim   obj.width ];
vRect = [0 0 obj.width obj.dim   ];

obj.allCoords = [
    CenterRectOnPoint(hRect, obj.center(1), obj.center(2))
    CenterRectOnPoint(vRect, obj.center(1), obj.center(2))
    ]';

end
