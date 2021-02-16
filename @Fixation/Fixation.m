classdef Fixation < baseObject
    
    
    %% Properties
    
    properties
        
        % Parameters
        
        screen_center_px   = zeros(0,2) % [ CenterX CenterY ], in pixels
        spacing_x_ratio    = zeros(0,1) % 0 to 1
        spacing_y_ratio    = zeros(0,1) % 0 to 1
        dimension_ratio    = zeros(0,1) % 0 to 1
        width_height_ratio = zeros(0,1) % 0 to 1
        color              = zeros(0,4) % [R G B a] from 0 to 255
        
        % Internal variables
        
        all_rects = zeros(4,10) % coordinates of the cross for PTB, in pixels
        x_pos     = zeros(1,5); % useful later to draw the circles at this coodinates
        y_pos     = zeros(1,5); % useful later to draw the circles at this coodinates
        
    end % properties
    
    
    %% Methods
    
    methods
        
        % -----------------------------------------------------------------
        %                           Constructor
        % -----------------------------------------------------------------
        function obj = Fixation( screen_center_px, spacing_x_ratio, spacing_y_ratio, dimension_ratio, width_height_ratio, color )
            
            % ================ Check input argument =======================
            
            % Arguments ?
            if nargin > 0
                
                obj.screen_center_px   = screen_center_px;
                obj.spacing_x_ratio    = spacing_x_ratio;
                obj.spacing_y_ratio    = spacing_y_ratio;
                obj.dimension_ratio    = dimension_ratio;
                obj.width_height_ratio = width_height_ratio;
                obj.color              = color;
                
                % ================== Callback =============================
                
                obj.GenerateCoords
                
            else
                % Create empty instance
            end
            
        end
        
        
    end % methods
    
    
end % class
