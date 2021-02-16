function LoadWavFile( obj )

if isempty( which('psychwavread') )
    [signal obj.fs] = wavread(obj.filename);
else
    [signal obj.fs] = psychwavread(obj.filename);
end
obj.signal      = [signal';signal'];
obj.time        = (0:1:length(obj.signal(1,:))-1)/obj.fs;
obj.duration    = length(obj.signal)/obj.fs;

end
