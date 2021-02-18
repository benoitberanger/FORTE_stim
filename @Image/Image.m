classdef Image < baseObject
    %IMAGE Class to load, prepare and draw image in PTB
    
    %% Properties
    
    properties
        
        % Parameters
        
        filename  % path of the image
        scale = 1 % scaling factor of the image => 1 means original image
        center    % [X-center-PTB, Y-center-PTB] in pixels, PTB coordinates
        mask = '' % mask of the images : str = 'NoMask', 'ShuffleMask', 'DarkMask'
        
        % Internal variables
        
        X         % image matrix
        map       % color map
        alpha     % transparency
        
        baseRect  % [x1 y1 x2 y2] pixels, PTB coordinates, original rectangle
        currRect  % [x1 y1 x2 y2] pixels, PTB coordinates, current  rectangle
        
        texPtr    % pointer to the texure in PTB
        
    end % properties
    
    
    %% Methods
    
    methods
        
        % -----------------------------------------------------------------
        %                           Constructor
        % -----------------------------------------------------------------
        function self = Image( filename, center, scale, mask )
            % self = Image( path = '../img/[subjectID]/test.png', center = [ CenterX CenterY ] (pixels), scale = 1  )
            
            % ================ Check input argument =======================
            
            % Arguments ?
            if nargin > 0
                
                % --- path ----
                assert( ischar(filename) && isvector(filename) && ~isempty(filename) , ...
                    'filename = path of the image' )
                assert( exist(filename,'file')>0 , '%s cannot be found' )
                self.filename = filename;
                self.Load
                
                % --- center ----
                if nargin > 1 && ~isempty(center)
                    self.Move(center);
                end
                
                % --- scale ----
                if nargin > 2 && ~isempty(scale)
                    self.Rescale(scale);
                end
                
                % --- mask ----
                if nargin > 3 && ~isempty(mask)
                    self.mask = mask;
                end
                
            else
                % Create empty instance
            end
            
        end
        
        
    end % methods
    
    
end % class
