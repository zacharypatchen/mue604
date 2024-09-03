classdef CSP_template < audioPlugin
    % downloaded from: bennettaudio.com
    
    properties
        % a property is a public variable that usually has a parameter
        % associated with it

        % PARAMETER_NAME = some value;

        ATTACK = 10; %milliseconds
        RELEASE = 50;
        RATIO = 2;
        THRESHOLD = -10;

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
                audioPluginGridLayout(...
                'RowHeight', [25 85 25 85 25 85 25 85],...
                'ColumnWidth',[85 85 85]),...
                audioPluginParameter('ATTACK', ...
                'DisplayName', 'Attack', ...
                'Style', 'rotaryknob',...
                'Mapping', {'lin', 0, 50},...
                'Layout', [6,1],...
                'DisplayNameLocation','above',...
                'Label', 'ms', ...
                'Filmstrip', 'dial.png',...
                'FilmstripFrameSize', [65 65] ...
                ),...%end of param
                audioPluginParameter('RELEASE', ...
                'DisplayName', 'Release', ...
                'Style', 'rotaryknob',...
                'Layout', [8, 1],...
                'DisplayNameLocation','above',...
                'Label', 'ms', ...
                'Mapping', {'lin', 0, 200}...
                ),...%end of param
                audioPluginParameter('THRESHOLD', ...
                'DisplayName', 'Threshold', ...
                'Style', 'rotaryknob',...
                'Layout', [2, 1],...
                'DisplayNameLocation','above',...
                'Label', 'dB', ...
                'Mapping', {'lin', -50, 0}...
                ),...%end of param
                audioPluginParameter('RATIO', ...
                'DisplayName', 'Ratio', ...
                'Style', 'rotaryknob',...
                'Layout', [4, 1],...
                'DisplayNameLocation','above',...
                'Label', ':1', ...
                'Mapping', {'int', 1, 12}...
                )...%end of param
                 ,audioPluginParameter('LF_SHELF',...
                'DisplayName', 'LF Shelf',...
                'Style', 'rotaryknob',...
                'Layout', [2, 2],...
                'DisplayNameLocation','above',...
                'Label', 'Hz',...
                'Mapping', {'log', 20, 400}), ... % end of parameter
            audioPluginParameter('LF_GAIN',...
                'DisplayName', 'LF Gain',...
                'Style', 'rotaryknob',...
                'Layout', [2, 3],...
                'DisplayNameLocation','above',...
                'Label', 'dB',...
                'Mapping', {'lin', -15, 15}), ... % end of parameter
            audioPluginParameter('MF_FREQ',...
                'DisplayName', 'MF Freq',...
                'Style', 'rotaryknob',...
                'Layout', [4, 2],...
                'DisplayNameLocation','above',...
                'Label', 'Hz', ...
                'Mapping', {'log', 200, 8000}), ... % end of parameter
            audioPluginParameter('MF_GAIN',...
                'DisplayName', 'MF Gain',...
                'Style', 'rotaryknob',...
                'Layout', [4, 3],...
                'DisplayNameLocation','above',...
                'Label', 'dB',...
                'Mapping', {'lin', -15, 15}), ... % end of parameter
            audioPluginParameter('HF_SHELF',...
                'DisplayName', 'HF Shelf',...
                'Style', 'rotaryknob',...
                'Layout', [6, 2],...
                'DisplayNameLocation','above',...
                'Label', 'Hz',...
                'Mapping', {'log', 2000, 16000}), ... % end of parameter
            audioPluginParameter('HF_GAIN',...
                'DisplayName', 'HF Gain',...
                'Style', 'rotaryknob',...
                'Layout', [6, 3],...
                'DisplayNameLocation','above',...
                'Label', 'dB',...
                'Mapping', {'lin', -15, 15}))  
        % end of interface
        
    end

    properties (Access = private)
        %internal filter variables, such as coefficient values
        FS = 44100;
        compressor;
         EQ;
         
    end
    
    methods
        function plugin = CSP_template()
             % Initialize Compressor
            plugin.compressor = compressor('MakeUpGainMode','Auto');
            updateCompressor(plugin);
plugin.EQ = multibandParametricEQ('SampleRate', plugin.FS, ...
                'NumEQBands', 3, ...
                'SampleRate', plugin.FS,...
                'Frequencies', [plugin.LF_SHELF, plugin.MF_FREQ, plugin.HF_SHELF], ...
                'PeakGains', [plugin.LF_GAIN, plugin.MF_GAIN, plugin.HF_GAIN]...
                );
            % Do any initializing that needs to occur BEFORE the plugin runs


        end

        function out = process(plugin,in)
            % DSP section
            %gain = db2mag(plugin.GAIN_DB);
            %out = gain * in;
            out = plugin.compressor(in) +plugin.EQ(in);
            
        end
        
        function reset(plugin)
            % this gets called if the sample rate changes or if the plugin
            % gets reloaded
            
            plugin.FS = getSampleRate(plugin);

            
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


        function updateEQ(plugin)
            plugin.EQ.Frequencies = [plugin.LF_SHELF, plugin.MF_FREQ, plugin.HF_SHELF];
            plugin.EQ.PeakGains = [plugin.LF_GAIN, plugin.MF_GAIN, plugin.HF_GAIN];
        end
        
       function set.THRESHOLD(plugin, val)
            plugin.THRESHOLD = val;
            updateCompressor(plugin);
        end

        function set.RATIO(plugin, val)
            plugin.RATIO = val;
            updateCompressor(plugin);
        end

        function set.ATTACK(plugin, val)
            plugin.ATTACK = val;
            updateCompressor(plugin);
        end

        function set.RELEASE(plugin, val)
            plugin.RELEASE = val;
            updateCompressor(plugin);
        end

        function updateCompressor(plugin)
            plugin.compressor.Threshold = plugin.THRESHOLD;
            plugin.compressor.Ratio = plugin.RATIO;
            plugin.compressor.AttackTime = plugin.ATTACK/1000;
            plugin.compressor.ReleaseTime = plugin.RELEASE/1000;
        end
        
    end
end