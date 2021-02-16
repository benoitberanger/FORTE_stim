classdef Text < baseObject
    %TEXT Class to print text in PTB
    
    %% Properties
    
    properties
        
        % Parameters
        
        color
        size
        
        content
        
        Xptb
        Yptb
        
        % Internal variables
        
        rect
        
    end % properties
    
    
    %% Methods
    
    methods
        
        % -----------------------------------------------------------------
        %                           Constructor
        % -----------------------------------------------------------------
        function self = Text( color, size, content, Xptb, Yptb )
            % obj = Text( color, size, content, Xptb, Yptb )
            
            % ================ Check input argument =======================
            
            % Arguments ?
            if nargin > 0
                
                self.color   = color;
                self.size    = size;
                self.content = content;
                self.Xptb    = Xptb;
                self.Yptb    = Yptb;
                
                % ================== Callback =============================
                
                self.rect = CenterRectArrayOnPoint([0 0 1 1], Xptb, Yptb);
                
            else
                % Create empty instance
            end
            
        end
        
        
    end % methods
    
    
end % class
