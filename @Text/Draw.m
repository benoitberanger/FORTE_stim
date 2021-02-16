function Draw( self, content )

if nargin > 1
    self.content = content;
end

Screen('TextSize' , self.wPtr, self.size);

%[nx, ny, textbounds, wordbounds] = DrawFormattedText(win, tstring [, sx][, sy][, color][, wrapat][, flipHorizontal][, flipVertical][, vSpacing][, righttoleft][, winRect])
DrawFormattedText(self.wPtr, self.content, 'center', 'center', self.color, [], [], [], [], [], self.rect);

end % function
