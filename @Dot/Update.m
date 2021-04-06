function Update( self, input_method )

switch input_method
    case 'Joystick'
        [self.Xptb, self.Yptb] = FORTE.QueryJoystickData( self.screenX, self.screenY );
    case 'Mouse'
        [self.Xptb, self.Yptb] = FORTE.QueryMouseData( self.wPtr, self.Xorigin, self.Yorigin, self.screenY );
    otherwise
        error('method ?')
end

self.Move(self.Xptb, self.Yptb)

end % function
