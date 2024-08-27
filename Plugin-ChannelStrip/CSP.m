classdef CSP< audioPlugin
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

        PluginInterface = audioPluginInterface(...
            'PluginName', 'Channel Strip Plugin',...
            'VendorName', 'Digital Audio Theory',...
            'VendorVersion', '1.0.0',...
            'UniqueId', 'DATc',...
            'BackgroundColor', [0.4157    0.7765    0.9333],...
            'BackgroundImage', 'bg.png',...
            audioPluginGridLayout(...
                'RowHeight', [25 85 25 85 25 85 25 25 85 25 90],...
                'ColumnWidth', [80 80 25 80]...
                ),...
            audioPluginParameter('BYPASS',...
                'DisplayName', 'Bypass',...
                'Style', 'vrocker',...
                'Mapping', {'enum', 'off', 'on'},...
                'Layout', [2,4],...
                'DisplayNameLocation', 'above',...
                'Filmstrip', 'switch_toggle.png',...
                'FilmstripFrameSize', [56 56]...
                ), ... %end of parameter    
            audioPluginParameter('GAIN_DB',...
                'Label', 'dB',...
                'DisplayName', 'Trim',...
                'Style', 'vslider',...
                'Mapping',{'lin',-12,12},...
                'Layout', [5,4; 6,4],...
                'DisplayNameLocation', 'above',...
                'Filmstrip', '76_bender.png',...
                'FilmstripFrameSize', [18 76]...
                ),... %end of parameter
            audioPluginParameter('LF_SHELF',...
                'DisplayName', 'LF Shelf',...
                'Label', 'Hz',...
                'Style', 'rotaryknob',...
                'Mapping', {'log', 20, 400},...
                'Layout', [2,1],...
                'DisplayNameLocation', 'above',...
                'Filmstrip', 'dial.png',...
                'FilmstripFrameSize', [65 65]...
                ), ... % end of parameter
            audioPluginParameter('LF_GAIN',...
                'DisplayName', 'LF Gain',...
                'Label', 'dB',...
                'Style', 'rotaryknob',...
                'Mapping', {'lin', -15, 15},...
                'Layout', [2,2],...
                'DisplayNameLocation', 'above',...
                'Filmstrip', 'dial.png',...
                'FilmstripFrameSize', [65 65]...
                ), ... % end of parameter
            audioPluginParameter('MF_FREQ',...
                'DisplayName', 'MF Freq',...
                'Label', 'Hz', ...
                'Style', 'rotaryknob',...
                'Mapping', {'log', 200, 8000},...
                'Layout', [4,1],...
                'DisplayNameLocation', 'above',...
                'Filmstrip', 'dial.png',...
                'FilmstripFrameSize', [65 65]...
                ), ... % end of parameter
            audioPluginParameter('MF_GAIN',...
                'DisplayName', 'MF Gain',...
                'Label', 'dB',...
                'Style', 'rotaryknob',...
                'Mapping', {'lin', -15, 15},...
                'Layout', [4,2],...
                'DisplayNameLocation', 'above',...
                'Filmstrip', 'dial.png',...
                'FilmstripFrameSize', [65 65]...
                ), ... % end of parameter
            audioPluginParameter('HF_SHELF',...
                'DisplayName', 'HF Shelf',...
                'Label', 'Hz',...
                'Style', 'rotaryknob',...
                'Mapping', {'log', 2000, 16000},...
                'Layout', [6,1],...
                'DisplayNameLocation', 'above',...
                'Filmstrip', 'dial.png',...
                'FilmstripFrameSize', [65 65]...
                ), ... % end of parameter
            audioPluginParameter('HF_GAIN',...
                'DisplayName', 'HF Gain',...
                'Label', 'dB',...
                'Style', 'rotaryknob',...
                'Mapping', {'lin', -15, 15},...
                'Layout', [6,2],...
                'DisplayNameLocation', 'above',...
                'Filmstrip', 'dial.png',...
                'FilmstripFrameSize', [65 65]...
                ),...% end of parameter
            audioPluginParameter('THRESHOLD',...
                'DisplayName', 'Threshold',...
                'Label', 'dB',...
                'Style', 'rotaryknob',...
                'Mapping', {'lin', -40, 0},...
                'Layout', [9,1],...
                'DisplayNameLocation', 'above',...
                'Filmstrip', 'dial.png',...
                'FilmstripFrameSize', [65 65]...
                ), ...% end of parameter
            audioPluginParameter('RATIO',...
                'DisplayName', 'Ratio',...
                'Style', 'rotaryknob',...
                'Label', ':1',...
                'Mapping', {'int', 1, 12},...
                'Layout', [9,2],...
                'DisplayNameLocation', 'above',...
                'Filmstrip', 'dial.png',...
                'FilmstripFrameSize', [65 65]...
                ), ...% end of parameter
            audioPluginParameter('ATTACK',...
                'DisplayName', 'Attack',...
                'Style', 'rotaryknob',...
                'Label', 'ms',...
                'Mapping', {'int', 1, 50},...
                'Layout', [11,1],...
                'DisplayNameLocation', 'above',...
                'Filmstrip', 'dial.png',...
                'FilmstripFrameSize', [65 65]...
                ), ...% end of parameter
            audioPluginParameter('RELEASE',...
                'DisplayName', 'Release',...
                'Style', 'rotaryknob',...
                'Label', 'ms',...
                'Mapping', {'int', 10, 1000},...
                'Layout', [11,2],...
                'DisplayNameLocation', 'above',...
                'Filmstrip', 'dial.png',...
                'FilmstripFrameSize', [65 65]...
                ), ...% end of parameter
            audioPluginParameter('DECAY',...
                'DisplayName', 'Absorb',...
                'Style', 'rotaryknob',...
                'Mapping', {'lin', 0, 1},...
                'Layout', [9,4],...
                'DisplayNameLocation', 'above',...
                'Filmstrip', 'dial.png',...
                'FilmstripFrameSize', [65 65]...
                ), ...% end of parameter
            audioPluginParameter('MIX',...
                'Style', 'rotaryknob',...
                'Label', '%',...
                'DisplayName', 'Mix',...
                'Mapping', {'int', 0, 100},...
                'Layout', [11,4],...
                'DisplayNameLocation', 'above',...
                'Filmstrip', 'dial.png',...
                'FilmstripFrameSize', [65 65]...
                ) ...% end of parameter
            ); %end of audioPluginInterface

    end

    properties (Access = private)
        %internal filter variables, such as coefficient values
        EQ;
        compressor;
        reverb;

    end

    methods
        function plugin = CSP()
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
                'ReleaseTime',plugin.RELEASE/1000,...
                'MakeUpGainMode','Auto');

            % Initialize Reverb
            plugin.reverb = reverberator('PreDelay', 0,...
                'WetDryMix', plugin.MIX/100,...
                'DecayFactor', plugin.DECAY);


        end

        function out = process(plugin,in)

            if strcmp(plugin.BYPASS, 'on')
                out = in;
                return;
            end

            out1 = coder.nullcopy(zeros(size(in)));
            out2 = coder.nullcopy(zeros(size(in))); 
            out3 = coder.nullcopy(zeros(size(in,1),2));
            out = coder.nullcopy(zeros(size(in)));

            gain = 10^(plugin.GAIN_DB/20);

            % apply DSP
            out1(:,:) = plugin.EQ(gain*in);
            out2(:,:) = plugin.compressor(out1);
            out3(:,:) = plugin.reverb(out2);

          %  out(:,:) = (out3(:,1)+out3(:,2))/2;
            out = out3;

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