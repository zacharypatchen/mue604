classdef CSP_AllFX< audioPlugin
    properties
        FS = 44100;

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

        % Compressor Parameters
        THRESHOLD = -10; % Threshold in dB
        RATIO = 4; % Ratio
        ATTACK = 10;
        RELEASE = 200;

        % Reverb Parameters
        DECAY = 0.5; % Decay (small value = big room)
        MIX = 50; % Wet/dry mix

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
                'Mapping',{'lin',-60,12}),... %end of parameter
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
                'Mapping', {'lin', -15, 15}),...
            audioPluginParameter('THRESHOLD',...
                'DisplayName', 'Threshold',...
                'Label', 'dB',...
                'Mapping', {'lin', -20, 0}), ...
            audioPluginParameter('RATIO',...
                'DisplayName', 'Ratio',...
                'Mapping', {'int', 1, 12}), ...
            audioPluginParameter('ATTACK',...
                'DisplayName', 'Attack',...
                'Label', 'ms',...
                'Mapping', {'int', 1, 50}), ...
            audioPluginParameter('RELEASE',...
                'DisplayName', 'Release',...
                'Label', 'ms',...
                'Mapping', {'int', 10, 1000}), ...
            audioPluginParameter('DECAY',...
                'DisplayName', 'Absorption',...
                'Mapping', {'lin', 0, 1}), ...
            audioPluginParameter('MIX',...
                'Label', '%',...
                'DisplayName', 'Mix',...
                'Mapping', {'int', 0, 100}) ...
            ); %end of audioPluginInterface

    end

    properties (Access = private)
        %internal filter variables, such as coefficient values
        EQ;
        compressor;
        reverb;

    end

    methods
        function plugin = CSP_AllFX(plugin)
            % setup multi-band EQ
            plugin.EQ = multibandParametricEQ('SampleRate', plugin.FS, ...
                'NumEQBands', 3, ...
                'SampleRate', plugin.FS,...
                'Frequencies', [plugin.LF_SHELF, plugin.MF_FREQ, plugin.HF_SHELF], ...
                'PeakGains', [plugin.LF_GAIN, plugin.MF_GAIN, plugin.HF_GAIN]...
                );

            % Initialize Compressor
            plugin.compressor = compressor('Threshold', plugin.THRESHOLD,...
                'Ratio', plugin.RATIO, ...
                'AttackTime',plugin.ATTACK/1000,...
                'ReleaseTime',plugin.RELEASE/1000);

            % Initialize Reverb
            plugin.reverb = reverberator('PreDelay', 0,...
                'WetDryMix', plugin.MIX/100,...
                'DecayFactor', plugin.DECAY);


        end

        function out = process(plugin,in)
            % DSP section
            if strcmp(plugin.BYPASS, 'on')
                out = in;
                return;
            end

            gain = 10^(plugin.GAIN_DB/20);

            % apply EQ
            in1 = gain*plugin.EQ(in);

            % Apply Compressor
            in2 = plugin.compressor(in1);

            % Apply Reverb
            out = plugin.reverb(in2);

        end

        function reset(plugin)
            % this gets called if the sample rate changes or if the plugin
            % gets reloaded

            plugin.FS = getSampleRate(plugin);


        end

        function set.GAIN_DB(plugin, val)
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


        function updateEQ(plugin)
            plugin.EQ.Frequencies = [plugin.LF_SHELF, plugin.MF_FREQ, plugin.HF_SHELF];
            plugin.EQ.PeakGains = [plugin.LF_GAIN, plugin.MF_GAIN, plugin.HF_GAIN];
        end

        % REVERB PARAMETERS
        function set.DECAY(plugin, val)
            plugin.DECAY = val;
            updateReverb(plugin);
        end

        function set.MIX(plugin, val)
            plugin.MIX = val;
            updateReverb(plugin);
        end

        function updateReverb(plugin)
            plugin.reverb.WetDryMix = plugin.MIX/100;
            plugin.reverb.DecayFactor = plugin.DECAY;
        end


        % COMPRESSOR PARAMETERS
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