classdef Instruction < baseObject
    
    
    %% Properties
    
    properties
        
        % Parameters
        
        screen_center_px   = zeros(0,2)  % from FIXATION
        x_pos              = zeros(1,5); % from FIXATION
        y_pos              = zeros(1,5); % from FIXATION
        
        color              = zeros(0,4)  % [R G B a] from 0 to 255
        diameter_ratio     = zeros(0,1)  % 0 to 1
        thickness_ratio    = zeros(0,1)  % 0 to 1

        % Internal variables
        
        all_rects = zeros(4,5) % coordinates of the cross for PTB, in pixels
        pen_width = zeros(0,1)  % thickness of the frame
        
    end % properties
    
    
    %% Methods
    
    methods
        
        % -----------------------------------------------------------------
        %                           Constructor
        % -----------------------------------------------------------------
        function obj = Instruction( FIXATION, color, diameter_ratio, thickness_ratio )
            
            % ================ Check input argument =======================
            
            % Arguments ?
            if nargin > 0
                
                obj.screen_center_px   = FIXATION.screen_center_px;
                obj.x_pos              = FIXATION.x_pos;
                obj.y_pos              = FIXATION.y_pos;

                obj.color              = color;
                obj.diameter_ratio     = diameter_ratio;
                obj.thickness_ratio    = thickness_ratio;
                
                % ================== Callback =============================
                
                obj.GenerateCoords
                obj.LinkToWindowPtr(FIXATION.wPtr);
                
            else
                % Create empty instance
            end
            
        end
        
        
    end % methods
    
    
end % class
