classdef CSP_simpleGain < audioPlugin
    properties
        % a property is a public variable that usually has a parameter
        % associated with it
        GAIN_DB=0;
        BYPASS = 'off';
        
    end

    properties (Constant)
        % this contains instructions to build your plugin GUI, usually
        % populated with audioPluginParamters that link to properties
        PluginInterface = audioPluginInterface(...
        audioPluginParameter('BYPASS',... 
            'DisplayName', 'Bypass',... 
            'Mapping', {'enum', 'off', 'on'}), ... %end of parameter 
        audioPluginParameter('GAIN_DB',...
            'Label', 'dB',...
            'DisplayName', 'Gain',...
            'Mapping',{'lin',-60,12})... %end of parameter
         ); %end of audioPluginInterface
        
    end

    properties (Access = private)
        %internal filter variables, such as coefficient values
        FS = 44100;

    end
    
    methods
        function plugin = CSP_simpleGain(plugin)
            % Nothing to initialize...
        end

        function out = process(plugin,in)
            % DSP section
            if strcmp(plugin.BYPASS, 'on')
                out = in;
                return;
            end


            gain = 10^(plugin.GAIN_DB/20);

            out=gain*in;

        end
        
        function reset(plugin)
            % this gets called if the sample rate changes or if the plugin
            % gets reloaded
            
            plugin.FS = getSampleRate(plugin);

            
        end
        
       function set.GAIN_DB(plugin, val)
            % anything to do here?
            plugin.GAIN_DB = val;
        end
        
    end
end