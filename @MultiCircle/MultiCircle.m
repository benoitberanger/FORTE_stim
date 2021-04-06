classdef MultiCircle < baseObject
    %MULTICIRCLE Class to prepare and draw a circle==target in PTB
    
    %% Properties
    
    properties
        
        % Parameters for the creation
        
        diameter          = zeros(0)   % in pixels
        thickness         = zeros(0)   % width of each arms, in pixels
        
        frameBaseColor    = zeros(4,0) % [R G B a] from 0 to 255
        diskBaseColor     = zeros(4,0) % [R G B a] from 0 to 255
        valueBaseColor    = zeros(4,0) % [R G B a] from 0 to 255
        
        Xorigin           = zeros(0)   % X coordiantes (in PTB referential) of the origin, in pixels
        Yorigin           = zeros(0)   % Y coordiantes (in PTB referential) of the origin, in pixels
        
        screenX           = zeros(0)   % number of horizontal pixels of the screen
        screenY           = zeros(0)   % number of vertical   pixels of the screen
        
        R                 = zeros(0)   % distance between (Xorigin,Yorigin) and the circle center
        THETA             = zeros(0)   % angle    between (Xorigin,Yorigin) and the circle center      
        
        % Internal variables
        
        frameCurrentColor = zeros(4,0) % [R G B a] from 0 to 255
        diskCurrentColor  = zeros(4,0) % [R G B a] from 0 to 255
        valueCurrentColor = zeros(4,0) % [R G B a] from 0 to 255
        
        Xptb              = zeros(0)   % X coordiantes in PTB referential of the center, in pixels
        Yptb              = zeros(0)   % Y coordiantes in PTB referential of the center, in pixels
        
        Rect              = zeros(4,0) % Rectangle for PTB draw Screen('FrameOval') function
        
        filled            = true       % flag to fill or not inside the circle
        valued            = 0          % flag to fill or not inside the circle
        
        value             = 40         % value from 0 to 100, to fill the disk
        
    end % properties
    
    
    %% Methods
    
    methods
        
        % -----------------------------------------------------------------
        %                           Constructor
        % -----------------------------------------------------------------
        function obj = MultiCircle( diameter, thickness, frameColor, diskColor, valueColor, Xorigin, Yorigin, screenX, screenY, R, THETA )
            
            % ================ Check input argument =======================
            
            % Arguments ?
            if nargin > 0
                
                % --- diameter ----
                assert( isscalar(diameter) && isnumeric(diameter) && diameter>0 , ...
                    'diameter = diameter of the circle, in pixels' )
                
                % --- thickness ----
                assert( isscalar(thickness) && isnumeric(thickness) && thickness>0 , ...
                    'thickness = thickness of the circle, in pixels' )
                
                % --- frameColor ----
                assert( isvector(frameColor) && isnumeric(frameColor) && all( uint8(frameColor)==frameColor ) , ...
                    'frameColor = [R G B a] from 0 to 255' )
                
                % --- diskColor ----
                assert( isvector(diskColor) && isnumeric(diskColor) && all( uint8(diskColor)==diskColor ) , ...
                    'diskColor = [R G B a] from 0 to 255' )
                
                % --- valueColor ----
                assert( isvector(valueColor) && isnumeric(valueColor) && all( uint8(valueColor)==valueColor ) , ...
                    'valueColor = [R G B a] from 0 to 255' )
                
                % --- Xorigin ----
                assert( isscalar(Xorigin) && isnumeric(Xorigin) && Xorigin>0 && Xorigin==round(Xorigin) , ...
                    'Xorigin = CenterX of the origin, in pixels' )
                
                % --- Yorigin ----
                assert( isscalar(Yorigin) && isnumeric(Yorigin) && Yorigin>0 && Yorigin==round(Yorigin) , ...
                    'Yorigin = CenterX of the origin, in pixels' )
                
                % --- screenX ----
                assert( isscalar(screenX) && isnumeric(screenX) && screenX>0 && screenX==round(screenX) , ...
                    'screenX = number of horizontal pixels of the PTB window' )
                
                % --- screenY ----
                assert( isscalar(screenY) && isnumeric(screenY) && screenY>0 && screenY==round(screenY) , ...
                    'screenY = number of vertical pixels of the PTB window' )
                
                obj.diameter          = diameter;
                obj.thickness         = thickness;
                obj.frameBaseColor    = frameColor;
                obj.frameCurrentColor = frameColor;
                obj.diskBaseColor     = diskColor;
                obj.diskCurrentColor  = diskColor;
                obj.valueBaseColor    = valueColor;
                obj.valueCurrentColor = valueColor;
                obj.Xorigin           = Xorigin;
                obj.Yorigin           = Yorigin;
                obj.screenX           = screenX;
                obj.screenY           = screenY;
                
                obj.R                 = R;
                obj.THETA             = THETA;
                
                % ================== Callback =============================
                
                obj.GenRect();
                N = numel(obj.THETA);
                obj.frameBaseColor    = repmat(frameColor' ,[1 N]);
                obj.frameCurrentColor = repmat(frameColor' ,[1 N]);
                obj.diskBaseColor     = repmat(diskColor'  ,[1 N]);
                obj.diskCurrentColor  = repmat(diskColor'  ,[1 N]);
                obj.valueBaseColor    = repmat(valueColor' ,[1 N]);
                obj.valueCurrentColor = repmat(valueColor' ,[1 N]);
                
            else
                % Create empty instance
            end
            
        end
        
        
    end % methods
    
    
end % class
