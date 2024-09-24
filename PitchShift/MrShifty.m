classdef MrShifty < audioPlugin
    properties
        % EQ parameters
        LF_FREQ = 100;
        MF_FREQ = 1000;
        HF_FREQ = 8000;
        
        LF_GAIN = 0;
        MF_GAIN = 0;
        HF_GAIN = 0;

        LF_Q = 0.707;
        MF_Q = 0.707;
        HF_Q = 0.707;
        %Pitch shift parameters
        % Amount of pitch shift (in semi-tones)
        % Valid ranges are from -12 to 12
        PITCHSHIFT = 0;
        % Delay line overlap
        OVERLAY = 0.45;
        %Pitch Mix
        PITCHSHIFT_MIX = 50.0;
        %Drive
        DRIVE = 0.0;
        
    end

    properties (Constant)
PluginInterface = audioPluginInterface(...
            'PluginName','Mr. Shifty',...
            'VendorName', 'Patch In Audio',...
            'VendorVersion', '1.0.0',...
            'UniqueId','DATg',...
                audioPluginGridLayout(...
                'RowHeight', [85 100 85 85 85 50 50],...
                'ColumnWidth',[25 85 100 85 25 85 100 85 25 85 100 85 25]),...
                audioPluginParameter("PITCHSHIFT",...
                DisplayName="Pitch", ...
                Label="semitones", ...
                DisplayNameLocation="above", ...
                Mapping={"int",-12,12}, ...
                Style="rotaryknob", Layout=[5 8], ...
                Filmstrip = 'dial.png', ...
                FilmstripFrameSize = [70 70]), ...
                audioPluginParameter("OVERLAY", ...
                DisplayName="Overlay", ...
                DisplayNameLocation="above", ...
                Mapping={"lin",.01,.5}, ...
                Style="rotaryknob", Layout=[5 12], ...
                Filmstrip = 'dial.png', ...
                FilmstripFrameSize = [70 70]),...  %end of param
                 audioPluginParameter('LF_FREQ',...
                'DisplayName', 'Lows',...
                'Style', 'rotaryknob',...
                'Layout', [2, 3],...
                'DisplayNameLocation','above',...
                'Label', 'Hz',...
                'Mapping', {'log', 20, 400}, ...
                'Filmstrip', 'dial.png',...
                'FilmstripFrameSize', [70 70]), ... % end of parameter
            audioPluginParameter('LF_GAIN',...
                'DisplayName', '-/+',...
                'Style', 'rotaryknob',...
                'Layout', [3, 4],...
                'DisplayNameLocation','above',...
                'Label', 'dB',...
                'Mapping', {'lin', -15, 15}, ...
                'Filmstrip', 'dial.png',...
                'FilmstripFrameSize', [70 70] ...
                ), ... % end of parameter
                audioPluginParameter('LF_Q',...
                'DisplayName', 'Q',...
                'Style', 'rotaryknob',...
                'Layout', [3, 2],...
                'DisplayNameLocation','above',...
                'Label', '',...
                'Mapping', {'lin', 0.1, 2.00}, ...
                'Filmstrip', 'dial.png',...
                'FilmstripFrameSize', [70 70] ...
                ), ... % end of parameter
            audioPluginParameter('MF_FREQ',...
                'DisplayName', 'Mids',...
                'Style', 'rotaryknob',...
                'Layout', [2, 7],...
                'DisplayNameLocation','above',...
                'Label', 'Hz', ...
                'Mapping', {'log', 200, 8000}, ...
                'Filmstrip', 'dial.png',...
                'FilmstripFrameSize', [70 70] ...
                ), ... % end of parameter
            audioPluginParameter('MF_GAIN',...
                'DisplayName', '-/+',...
                'Style', 'rotaryknob',...
                'Layout', [3, 8],...
                'DisplayNameLocation','above',...
                'Label', 'dB',...
                'Mapping', {'lin', -15, 15}, ...
                'Filmstrip', 'dial.png',...
                'FilmstripFrameSize', [70 70] ...
                ), ... % end of parameter
                audioPluginParameter('MF_Q',...
                'DisplayName', 'Q',...
                'Style', 'rotaryknob',...
                'Layout', [3, 6],...
                'DisplayNameLocation','above',...
                'Label', '',...
                'Mapping', {'lin', 0.1, 2.00}, ...
                'Filmstrip', 'dial.png',...
                'FilmstripFrameSize', [70 70] ...
                ), ... % end of parameter
            audioPluginParameter('HF_FREQ',...
                'DisplayName', 'Highs',...
                'Style', 'rotaryknob',...
                'Layout', [2, 11],...
                'DisplayNameLocation','above',...
                'Label', 'Hz',...
                'Mapping', {'log', 2000, 16000}, ...
                'Filmstrip', 'dial.png',...
                'FilmstripFrameSize', [70 70] ...
                ), ... % end of parameter
            audioPluginParameter('HF_GAIN',...
                'DisplayName', '-/+',...
                'Style', 'rotaryknob',...
                'Layout', [3, 12],...
                'DisplayNameLocation','above',...
                'Label', 'dB',...
                'Mapping', {'lin', -15, 15}, ...
                'Filmstrip', 'dial.png',...
                'FilmstripFrameSize', [70 70] ...
                ), ...
                audioPluginParameter('HF_Q',...
                'DisplayName', 'Q',...
                'Style', 'rotaryknob',...
                'Layout', [3, 10],...
                'DisplayNameLocation','above',...
                'Label', 'dB',...
                'Mapping', {'lin', 0.1, 2.00}, ...
                'Filmstrip', 'dial.png',...
                'FilmstripFrameSize', [70 70] ...
                ), ...
                audioPluginParameter('DRIVE',...
                'DisplayName', 'Error',...
                'Style', 'rotaryknob',...
                'Layout', [5,3 ; 6,5],...
                'DisplayNameLocation', 'above',...
                'Label', '%',...
                'Mapping', {'lin', 0, 100.0}, ...
                'Filmstrip', 'BigKnob.png',...
                'FilmstripFrameSize', [89 89]),...
                audioPluginParameter('PITCHSHIFT_MIX',...
                'DisplayName', 'Mix',...
                'Style', 'rotaryknob',...
                'Layout', [5,9;6,11],...
                'DisplayNameLocation', 'above',...
                'Label', '%',...
                'Mapping', {'lin', 1.0, 100.0}, ...
                'Filmstrip', 'BigKnob.png',...
                'FilmstripFrameSize', [89 89]),...
                'BackgroundImage','PatchBackground.jpg')
        % end of interface
    end

    properties (Access = private)
        % Sample rate
        FS = 44100;

        % Pitch Shifter
        PitchShifter;
        pitchMixSmoother;
        pitchSmoother;
        overlaySmoother;
        % Diode clipping parameters
        Vt = 0.0253;
        eta = 1.68;
        Is = 0.105;

        driveSmoother;

        % Filter structures with persistent variables
        lowFreqFilter = struct('w', [0 0 ; 0 0], 'a0', 1, 'a1', 0, 'a2', 0, 'b0', 1, 'b1', 0, 'b2', 0, 'x1', 0, 'x2', 0, 'y1', 0, 'y2', 0);
        midFreqFilter = struct('w', [0 0 ; 0 0], 'a0', 1, 'a1', 0, 'a2', 0, 'b0', 1, 'b1', 0, 'b2', 0, 'x1', 0, 'x2', 0, 'y1', 0, 'y2', 0);
        highFreqFilter = struct('w', [0 0 ; 0 0], 'a0', 1, 'a1', 0, 'a2', 0, 'b0', 1, 'b1', 0, 'b2', 0, 'x1', 0, 'x2', 0, 'y1', 0, 'y2', 0);

        lowFreqSmoother;
        lowFreqGainSmoother;
        lowFreqQSmoother;
        midFreqSmoother;
        midFreqGainSmoother;
        midFreqQSmoother;
        highFreqSmoother;
        highFreqGainSmoother;
        highFreqQSmoother;
    end

    methods
        function plugin = MrShifty()
            % Initialize Pitch Shifter
            plugin.PitchShifter = audiopluginexample.PitchShifter();
            plugin.pitchMixSmoother = ParameterSmoother(plugin.PITCHSHIFT_MIX, 0.5);
            plugin.pitchSmoother = ParameterSmoother(plugin.PITCHSHIFT, 0.9);
            plugin.overlaySmoother = ParameterSmoother(plugin.OVERLAY, 0.9);
            %initialize LF param smoother
            plugin.lowFreqSmoother = ParameterSmoother(plugin.LF_FREQ, 0.9);
            plugin.lowFreqGainSmoother = ParameterSmoother(plugin.LF_GAIN, 0.9);
            plugin.lowFreqQSmoother = ParameterSmoother(plugin.LF_Q, 0.9);
            %initialize mf param smoother
            plugin.midFreqSmoother = ParameterSmoother(plugin.MF_FREQ, 0.9);
            plugin.midFreqGainSmoother = ParameterSmoother(plugin.MF_GAIN, 0.9);
            plugin.midFreqQSmoother = ParameterSmoother(plugin.MF_Q, 0.9);
            %initialize hf param smoother
            plugin.highFreqSmoother = ParameterSmoother(plugin.HF_FREQ, 0.9);
            plugin.highFreqGainSmoother = ParameterSmoother(plugin.HF_GAIN, 0.9);
            plugin.highFreqQSmoother = ParameterSmoother(plugin.HF_Q, 0.9);
            %Initialize drive
            plugin.driveSmoother = ParameterSmoother(plugin.DRIVE, 0.2);
        end

        function out = process(plugin, in)
            % DSP section
            out = coder.nullcopy(zeros(size(in)));

            % Mix factor for pitch shifting
            mixFactor = plugin.PITCHSHIFT_MIX / 100.0;

            % Pitch shifting and mix
            shiftedSignal = plugin.PitchShifter(in);
            pitchMixed = (1 - mixFactor) * in + mixFactor * shiftedSignal;

            % Diode clipping 
            clipped = zeros(size(pitchMixed)); % Preallocate the clipped signal

            for n = 1:length(pitchMixed)
                clipped(n, :) = plugin.Is * (exp(((plugin.DRIVE / 100 + 0.1) * pitchMixed(n, :)) / (plugin.eta * plugin.Vt)) - 1);
            end


            % EQ processing for each band (low, mid, high)
            for ch = 1:min(size(clipped))
       
                x = clipped(:,ch);
                
                [x, plugin.lowFreqFilter.w(:,ch)] = processBiquad(x, plugin.lowFreqFilter, ch);
                [x, plugin.midFreqFilter.w(:,ch)] = processBiquad(x, plugin.midFreqFilter, ch);
                [x, plugin.highFreqFilter.w(:,ch)] = processBiquad(x, plugin.highFreqFilter, ch);


            end
            % Sum all filtered outputs (low, mid, high)
            out = x;
        end


        function reset(plugin)
            % Called when sample rate changes or plugin is reloaded
            plugin.FS = getSampleRate(plugin);
            plugin.lowFreqFilter.w = [0 0; 0 0];
            plugin.midFreqFilter.w = [0 0; 0 0];
            plugin.highFreqFilter.w = [0 0; 0 0];
        end

        % Drive params

        function set.DRIVE(plugin, val)
            plugin.DRIVE = val;
            plugin.driveSmoother.setTargetValue(val);
            plugin.driveSmoother.step();
        end

        function set.PITCHSHIFT(plugin, val)
            plugin.PITCHSHIFT = val;
            plugin.pitchSmoother.setTargetValue(val);
            plugin.pitchSmoother.step();
            updatePitchShifter(plugin);
        end

        function set.OVERLAY(plugin, val)
            plugin.OVERLAY = val;
            plugin.overlaySmoother.setTargetValue(val);
            plugin.overlaySmoother.step();
            updatePitchShifter(plugin);
        end

        function set.PITCHSHIFT_MIX(plugin, val)
            plugin.PITCHSHIFT_MIX = val;
            plugin.pitchMixSmoother.setTargetValue(val);
            plugin.pitchMixSmoother.step();
        end

        function updatePitchShifter(plugin)
            plugin.PitchShifter.PitchShift = plugin.PITCHSHIFT;
            plugin.PitchShifter.Overlap = plugin.OVERLAY;
        end

        % Low Frequency EQ updates
        function set.LF_FREQ(plugin, val)
            plugin.LF_FREQ = val;
            plugin.lowFreqSmoother.setTargetValue(val);
            updateLowFreqFilter(plugin);
        end
        
        function set.LF_Q(plugin, val)
            plugin.LF_Q = val;
            plugin.lowFreqQSmoother.setTargetValue(val);
            updateLowFreqFilter(plugin);
        end

        function set.LF_GAIN(plugin, val)
            plugin.LF_GAIN = val;
            plugin.lowFreqGainSmoother.setTargetValue(val);
            updateLowFreqFilter(plugin);
        end

        function updateLowFreqFilter(plugin)

            Q=plugin.lowFreqQSmoother.step();
            f0=plugin.lowFreqSmoother.step();
            gain = plugin.lowFreqGainSmoother.step();
            w0=2*pi*f0/plugin.FS;
            alpha=sin(w0)/(2*Q);
            A=sqrt(db2mag(gain));

            plugin.lowFreqFilter.a0 =   1 + alpha*A;
            plugin.lowFreqFilter.a1 =  -2*cos(w0);
            plugin.lowFreqFilter.a2 =   1 - alpha*A;
            plugin.lowFreqFilter.b0 =   1 + alpha/A;
            plugin.lowFreqFilter.b1 =  -2*cos(w0);
            plugin.lowFreqFilter.b2 =   1 - alpha/A;
        end

        % Mid Frequency EQ updates
        function set.MF_FREQ(plugin, val)
            plugin.MF_FREQ = val;
            plugin.midFreqSmoother.setTargetValue(val);
            updateMidFreqFilter(plugin);
        end

        function set.MF_GAIN(plugin, val)
            plugin.MF_GAIN = val;
            plugin.midFreqGainSmoother.setTargetValue(val);
            updateMidFreqFilter(plugin);
        end

        function set.MF_Q(plugin, val)
            plugin.MF_Q = val;
            plugin.midFreqQSmoother.setTargetValue(val);
            updateMidFreqFilter(plugin);
        end

        function updateMidFreqFilter(plugin)

            Q=plugin.midFreqQSmoother.step();
            f0=plugin.midFreqSmoother.step();
            gain = plugin.midFreqGainSmoother.step();
            w0=2*pi*f0/plugin.FS;
            alpha=sin(w0)/(2*Q);
            A=sqrt(db2mag(gain));

            plugin.midFreqFilter.a0 =   1 + alpha*A;
            plugin.midFreqFilter.a1 =  -2*cos(w0);
            plugin.midFreqFilter.a2 =   1 - alpha*A;
            plugin.midFreqFilter.b0 =   1 + alpha/A;
            plugin.midFreqFilter.b1 =  -2*cos(w0);
            plugin.midFreqFilter.b2 =   1 - alpha/A;
        end

        % High Frequency EQ updates
        function set.HF_FREQ(plugin, val)
            plugin.HF_FREQ = val;
            plugin.highFreqSmoother.setTargetValue(val);
            updateHighFreqFilter(plugin);
        end
        
        function set.HF_Q(plugin, val)
            plugin.HF_Q = val;
            plugin.highFreqQSmoother.setTargetValue(val);
            updateHighFreqFilter(plugin);
        end

        function set.HF_GAIN(plugin, val)
            plugin.HF_GAIN = val;
            plugin.highFreqGainSmoother.setTargetValue(val);
            updateHighFreqFilter(plugin);
        end

        function updateHighFreqFilter(plugin)

            Q=plugin.highFreqQSmoother.step();
            f0=plugin.highFreqSmoother.step();
            gain = plugin.highFreqGainSmoother.step();
            w0=2*pi*f0/plugin.FS;
            alpha=sin(w0)/(2*Q);
            A=sqrt(db2mag(gain));

            plugin.highFreqFilter.a0 =   1 + alpha*A;
            plugin.highFreqFilter.a1 =  -2*cos(w0);
            plugin.highFreqFilter.a2 =   1 - alpha*A;
            plugin.highFreqFilter.b0 =   1 + alpha/A;
            plugin.highFreqFilter.b1 =  -2*cos(w0);
            plugin.highFreqFilter.b2 =   1 - alpha/A;
        end
    end
end