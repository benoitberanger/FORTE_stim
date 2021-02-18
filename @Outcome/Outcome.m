classdef Outcome < baseObject
    
    %% Properties
    
    properties
        
        % Parameters
        dimension_ratio  = zeros(0,1) % 0 to 1
        screen_center_px = zeros(0,2) % [ CenterX CenterY ], in pixels
        
        % Internal variables
        high_reward
        low_reward
        total
        
        
    end % properties
    
    %% Methods
    
    methods
        
        % -----------------------------------------------------------------
        %                           Constructor
        % -----------------------------------------------------------------
        function obj = Outcome( path_to_10euro, path_to_1cent, dimension_ratio, screen_center_px,...
                font_color, font_size)
            
            % ================ Check input argument =======================
            
            % Arguments ?
            if nargin > 0
                
                obj.dimension_ratio  = dimension_ratio;
                obj.screen_center_px = screen_center_px;
                                
                % ================== Callback =============================
                
                obj.high_reward = Image( path_to_10euro, screen_center_px );
                obj.low_reward  = Image( path_to_1cent, screen_center_px );
                
                obj.total = Text(font_color, screen_center_px(2)*font_size, '0', screen_center_px(1), screen_center_px(2));
                
            else
                % Create empty instance
            end
            
        end
        
        
    end % methods
    
    
end % class
