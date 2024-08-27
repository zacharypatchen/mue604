classdef CSP_template < audioPlugin
    % downloaded from: bennettaudio.com
    
    properties
        % a property is a public variable that usually has a parameter
        % associated with it

        % PARAMETER_NAME = some value;

        GAIN_DB = 0;
        ATTACK = 10; %milliseconds
        RELEASE = 50;
        RATIO = 2;
        THRESHOLD = -10;
    end

    properties (Constant)
        % this contains instructions to build your plugin GUI, usually
        % populated with audioPluginParamters that link to properties
        
        % parameters have:
        % a function call - audioPluginParameter('PARAMETER_NAME',...
        %'DisplayName'
        %'Label'
        %'Mapping': 'lin', 'log', 'pow', 'int', 'enum'

        PluginInterface = audioPluginInterface(...
            'PluginName','SimpleGain',...
            'VendorName', 'DigitalAudioTheory1',...
            'VendorVersion', '1.0.0',...
            'UniqueId','DATg',...
                audioPluginParameter('GAIN_DB', ...
                'DisplayName', 'Trim', ...
                'Label', 'dB', ...
                'Mapping', {'lin', -12, 12}...
                ),...%end of param
                audioPluginParameter('ATTACK', ...
                'DisplayName', 'Attack', ...
                'Label', 'ms', ...
                'Mapping', {'lin', 0, 50}...
                ),...%end of param
                audioPluginParameter('RELEASE', ...
                'DisplayName', 'Release', ...
                'Label', 'ms', ...
                'Mapping', {'lin', 0, 200}...
                ),...%end of param
                audioPluginParameter('THRESHOLD', ...
                'DisplayName', 'Threshold', ...
                'Label', 'dB', ...
                'Mapping', {'lin', -50, 0}...
                ),...%end of param
                audioPluginParameter('RATIO', ...
                'DisplayName', 'Ratio', ...
                'Label', ':1', ...
                'Mapping', {'int', 1, 12}...
                )...%end of param
            )...% end of interface 
        
    end

    properties (Access = private)
        %internal filter variables, such as coefficient values
        FS = 44100;
        
    end
    
    methods
        function plugin = CSP_template()
            % Do any initializing that needs to occur BEFORE the plugin runs


        end

        function out = process(plugin,in)
            % DSP section
            gain = db2mag(plugin.GAIN_DB);
            out = gain * in;
            
        end
        
        function reset(plugin)
            % this gets called if the sample rate changes or if the plugin
            % gets reloaded
            
            plugin.FS = getSampleRate(plugin);

            
        end
        
        function set.GAIN_DB(plugin, val)
            plugin.GAIN_DB = val;


        end
       
        
    end
end