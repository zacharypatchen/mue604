classdef CSP_EQ3band < audioPlugin
    properties
        % channel gain
        GAIN_DB=0;
        BYPASS='off';

        % EQ parameters
        LF_SHELF = 100;
        MF_FREQ = 1000;
        HF_SHELF = 8000;

        LF_GAIN = 0;
        MF_GAIN = 0;
        HF_GAIN = 0;
        
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
            'Mapping',{'lin',-60,15}),... %end of parameter
        audioPluginParameter('LF_SHELF',... 
            'DisplayName', 'LF Shelf',... 
            'Label', 'Hz',...
            'Mapping', {'log', 20, 400}), ... % end of parameter
        audioPluginParameter('LF_GAIN',... 
            'DisplayName', 'LF Gain',... 
            'Label', 'dB',... 
            'Mapping', {'lin', -15, 15}), ... % end of parameter
        audioPluginParameter('MF_FREQ',... 
            'DisplayName', 'MF Freq',... 
            'Label', 'Hz', ...
            'Mapping', {'log', 200, 8000}), ... % end of parameter
        audioPluginParameter('MF_GAIN',... 
            'DisplayName', 'MF Gain',... 
            'Label', 'dB',... 
            'Mapping', {'lin', -15, 15}), ... % end of parameter
        audioPluginParameter('HF_SHELF',... 
            'DisplayName', 'HF Shelf',... 
            'Label', 'Hz',...
            'Mapping', {'log', 2000, 16000}), ... % end of parameter
        audioPluginParameter('HF_GAIN',... 
            'DisplayName', 'HF Gain',... 
            'Label', 'dB',... 
            'Mapping', {'lin', -15, 15})... % end of parameter  
        ); %end of audioPluginInterface
        
    end

    properties (Access = private)
        %internal filter variables, such as coefficient values
        FS=44100;
        EQ;
        
    end
    
    methods
        function plugin = CSP_EQ3band(plugin)
            % setup multi-band EQ
            plugin.EQ = multibandParametricEQ(...
                'NumEQBands', 3, ...
                'SampleRate', plugin.FS);
            updateEQ(plugin);

        end

        function updateEQ(plugin)
           plugin.EQ.Frequencies = [plugin.LF_SHELF, plugin.MF_FREQ, plugin.HF_SHELF];
           plugin.EQ.PeakGains = [plugin.LF_GAIN, plugin.MF_GAIN, plugin.HF_GAIN];
        end

        function out = process(plugin,in)
            % DSP section
            if strcmp(plugin.BYPASS, 'on')
                out = in;
                return;
            end

            gain = 10^(plugin.GAIN_DB/20);

            out = gain*plugin.EQ(in);
            
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


       function set.LF_SHELF(plugin, val)
            plugin.LF_SHELF = val;
            updateEQ(plugin);
       end
    
       function set.LF_GAIN(plugin, val)
           plugin.LF_GAIN = val;
           updateEQ(plugin);
       end
    
       function set.MF_FREQ(plugin, val)
           plugin.MF_FREQ = val;
           updateEQ(plugin);
       end
    
       function set.MF_GAIN(plugin, val)
           plugin.MF_GAIN = val;
           updateEQ(plugin);
       end
    
      
       function set.HF_SHELF(plugin, val)
           plugin.HF_SHELF = val;
           updateEQ(plugin);
       end
    
       function set.HF_GAIN(plugin, val)
           plugin.HF_GAIN = val;
           updateEQ(plugin);
       end
    

    end
end