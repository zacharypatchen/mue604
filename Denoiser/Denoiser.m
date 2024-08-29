classdef Denoiser < audioPlugin
    %DENOISER Denoise speech using a deep neural network
    %   dn = audiopluginexample.Denoiser returns an audio plugin, dn, that
    %   removes washing machine background noise from a speech signal using
    %   a deep neural network. For details on training the neural network,
    %   refer to the 'Denoise Speech Using Deep Learning Networks' example.
    %   The plugin includes an optional configurable noise gate at the
    %   output of the network.
    %
    %   Denoiser methods:
    %   process       - Denoise input signal
    %   reset         - Reset internal states to initial conditions
    %
    %   Denoiser properties:
    %   BypassNoiseGate - Bypass noise gate
    %   Threshold       - Noise gate threshold (dB)
    %   AttackTime      - Noise gate attack time (s)
    %   ReleaseTime     - Noise gate release time (s)
    %   HoldTime        - Noise gate hold time (s)
    %
    %   % Example 1: Denoise signal in MATLAB
    %
    %   % Download the pretrained denoising network. For details on the
    %   % design and training of the network, refer to the 'Denoise Speech
    %   % Using Deep Learning Networks' example.
    %   url = 'https://ssd.mathworks.com/supportfiles/audio/SpeechDenoising.zip';
    %   downloadNetFolder = pwd;
    %   netFolder = fullfile(downloadNetFolder,'SpeechDenoising');
    %   if ~exist(netFolder,'dir')
    %     disp('Downloading pretrained network (1 file - 8 MB) ...')
    %     unzip(url,downloadNetFolder)
    %   end
    %
    %   % The downloaded MAT file contains two networks. Create a new MAT
    %   % file that only contains the network used by the denoiser plugin.
    %   s = load(fullfile(netFolder,'denoisenet.mat'));
    %   denoiseNetFullyConnected = s.denoiseNetFullyConnected;
    %   save('denoisePluginNet.mat','denoiseNetFullyConnected')
    %
    %   % Create an audio file reader object. Select an audio file
    %   % containing speech corrupted by washing machine noise.
    %   filename = 'RainbowNoisy-16-8-mono-114secs.wav';
    %   reader = dsp.AudioFileReader(filename, 'SamplesPerFrame',128);
    %
    %   % Create an audio device writer object to play the denoised speech
    %   player = audioDeviceWriter('SampleRate', reader.SampleRate);
    %
    %   % Create a denoiser plugin. Set the plugin sample rate to the audio
    %   % file's sample rate.
    %   denoiser = audiopluginexample.Denoiser;
    %   setSampleRate(denoiser, reader.SampleRate);
    % 
    %   while ~isDone(reader)
    %       x = reader();
    %       y = process(denoiser, x);
    %       player(y);
    %   end
    %   release(reader)
    %   release(player)
    %
    %   % Example 2: Launch a test bench for the denoiser object
    %   denoiser = audiopluginexample.Denoiser;
    %   audioTestBench(denoiser);
    %
    %   See also: audiopluginexample.PitchShifter, audiopluginexample.Echo

    %   Copyright 2021-2023 The MathWorks, Inc.
    
    %#codegen

    properties
        %BypassNoiseGate Bypass noise gate
        % Specify whether the noise gate is active or not. Set this
        % property to false to activate the noise gate. The default is
        % true.
        BypassNoiseGate = true
        %Threshold Operation threshold (dB)
        %   Specify the threshold, in dB, below which noise gate gain
        %   adjustment starts. The default is -35 dB.
        Threshold = -35
        %AttackTime Attack time (s)
        %   Specify the attack time in seconds as a scalar finite real
        %   value greater than or equal to 0. The attack time is defined as
        %   the time it takes the gain to rise from 10% to 90% of its final
        %   absolute value when the input level goes below the threshold.
        %   The default is 0.5 seconds.
        AttackTime = 0.5
        %ReleaseTime Release time (s)
        %   Specify the release time in seconds as a scalar finite real
        %   value greater than or equal to 0. The release time is defined
        %   as the time it takes the gain to drop from 90% to 10% of its
        %   value when the input goes above the threshold. The default is
        %   0.3 seconds.
        ReleaseTime = 0.3
        %HoldTime Hold time (s)
        %   Specify the hold time in seconds as a scalar finite real value
        %   greater than or equal to 0. The hold time is defined as the
        %   period for which the gate remains open before starting to close
        %   when the input level drops below the threshold. The default is
        %   0 seconds.
        HoldTime = 0
    end

    properties (Constant)
        % audioPluginInterface manages the number of input/output channels
        % and uses audioPluginParameter to generate plugin UI parameters.
        PluginInterface = audioPluginInterface(...
            audioPluginParameter('BypassNoiseGate','DisplayName','Bypass noise gate','Mapping',{'enum','off','on'},'Layout',[1 1; 1 2]),...
            audioPluginParameter('Threshold','DisplayName','Threshold','Label','dB','Mapping',{'lin',-140,0},'Style','rotaryknob','Layout',[2 1]),...
            audioPluginParameter('AttackTime','DisplayName','Attack time','Label','s','Mapping',{'lin',0,5},'Style','rotaryknob','Layout',[4 1]),...
            audioPluginParameter('ReleaseTime','DisplayName','Release time','Label','s','Mapping',{'lin',0,5},'Style','rotaryknob','Layout',[2 2]),...
            audioPluginParameter('HoldTime','DisplayName','Hold time','Label','s','Mapping',{'lin',0,5},'Style','rotaryknob','Layout',[4 2]),...
            audioPluginGridLayout('RowHeight', [20 200 20 100 20], ...
            'ColumnWidth', [100 100], 'Padding', [10 10 10 30]), ...
            'InputChannels',1,...
            'OutputChannels',1,...
            'PluginName','Denoiser')
    end

    properties (Constant)
        % Define audio plugin configuration parameters. Specify a deep
        % learning configuration object with target set to 'mkldnn' to
        % generate code for Intel (R) MKLDNN library. Specify Intel AVX for
        % a code replacement library.
        PluginConfig = audioPluginConfig( ...
            'DeepLearningConfig',coder.DeepLearningConfig('mkldnn'),...
            'CodeReplacementLibrary', 'DSP Intel AVX2-FMA (Mac)');
    end

    properties (Access = private)
        % stf Short-time Fourier transform (STFT) object. Converts the
        % audio time-series signal to STFT before feeding it to the
        % denoising neural network.
        stf
        % istf Inverse STFT (ISTFT) object. Converts the STFT at the output
        % of the neural network to a time-series audio signal.
        istf
        % segmentBuffer STFT segment buffer. Used to feed the 8 most recent
        % STFT segments to the neural network.
        segmentBuffer
        % bufferOut Buffer at the output of the neural network after ISTFT
        bufferOut
        % bufferNN Buffer at the output of src1
        bufferNN
        % buffer Buffer at output
        buffer
        % ng Noise gate
        ng

        % Sample-rate conversion utilities
        src16To8
        src441To8
        src48To8
        src96To8
        src192To8
        src32To8
        buffTo8

        src16From8
        src441From8
        src48From8
        src96From8
        src192From8
        src32From8
        buffFrom8
    end

    methods

        function plugin = Denoiser()
            % Initialize internal objects
            WindowLength = 256;
            win = hamming(WindowLength,'periodic');
            Overlap = round(0.75 * WindowLength);
            FFTLength = WindowLength;
            plugin.stf  = dsp.STFT(win,Overlap,FFTLength,...
                'FrequencyRange','onesided');
            plugin.istf = dsp.ISTFT(win,Overlap,...
                'WeightedOverlapAdd',false,...
                'FrequencyRange','onesided');

            plugin.segmentBuffer = dsp.AsyncBuffer('Capacity',8);
            plugin.bufferOut = dsp.AsyncBuffer;
            plugin.bufferNN = dsp.AsyncBuffer;
            plugin.buffer = dsp.AsyncBuffer;
            
            plugin.ng = noiseGate('Threshold',-35, ...
                                  'AttackTime',.5, ...
                                  'ReleaseTime',.3, ...
                                  'HoldTime',0, ...
                                  'SampleRate',8000);

            plugin.src16From8 = dsp.FIRInterpolator(2);
            plugin.src441From8 = dsp.FIRRateConverter(441,80);
            plugin.src48From8 = dsp.FIRInterpolator(6);
            plugin.src96From8 = dsp.FIRInterpolator(12);
            plugin.src192From8 = dsp.FIRInterpolator(24);
            plugin.src32From8 = dsp.FIRInterpolator(4);
            plugin.buffFrom8 = dsp.AsyncBuffer;

            plugin.src16To8 = dsp.FIRDecimator(2);
            plugin.src441To8 = dsp.FIRRateConverter(80,441);
            plugin.src48To8 = dsp.FIRDecimator(6);
            plugin.src96To8 = dsp.FIRDecimator(12);
            plugin.src192To8 = dsp.FIRDecimator(24);
            plugin.src32To8 = dsp.FIRDecimator(4);
            plugin.buffTo8 = dsp.AsyncBuffer;

        end
        
        function set.ReleaseTime(plugin,val)
            plugin.ng.ReleaseTime = val; %#ok
            plugin.ReleaseTime = val;
        end
        
        function set.AttackTime(plugin,val)
            plugin.ng.AttackTime = val; %#ok
            plugin.AttackTime = val;
        end
        
        function set.HoldTime(plugin,val)
            plugin.ng.HoldTime = val; %#ok
            plugin.HoldTime = val;
        end
        
        function set.Threshold(plugin,val)
            plugin.ng.Threshold = val; %#ok
            plugin.Threshold = val;
        end
        
        function reset(plugin)
            % RESET Reset internal states to initial conditions
            reset(plugin.ng);
        end

        function out = process(plugin,in)
            % PROCESS Denoise speech signal
            %
            % audioOut = PROCESS(dn,audioIn) denoises the input audio
            % signal, audioIn.
            
            dt = class(in);
            in = single(in);
            
            fs = getSampleRate(plugin);
            
            % Convert signal to 8 kHz
            x = convertTo8kHz(plugin,in, fs);

            % Write 8 kHz signal to buffer
            write(plugin.bufferNN,x(:,1:size(in,2)));

            % The denoising neural network operates on audio frames of
            % length 64.
            numSamples = double(plugin.bufferNN.NumUnreadSamples);
            numFrames = floor(numSamples/64);

            z = zeros(64*numFrames,1,'single');

            for index=1:numFrames

                frame = read(plugin.bufferNN, 64);
                sftSeg  = plugin.stf(frame);
                sftSeg = sftSeg(1:129,1);
                
                % Write most recent STFT vector to buffer
                write(plugin.segmentBuffer,abs(sftSeg).');

                % Read most recent 8 STFT vectors
                SFFT_Image = read(plugin.segmentBuffer,8,7).';

                % Denoise. Y is the STFT of the denoised frame
                Y = denoise(reshape(SFFT_Image,[129 8 1])).';

                % Inverse STFT. Use phase of noisy input audio
                isftSeg      = Y.*exp(1j * angle(sftSeg));

                z((index-1)*64+1:index*64) = plugin.istf(isftSeg);
            end

            if ~plugin.BypassNoiseGate
                z = plugin.ng(z);
            end

            % Convert from 8 kHz back to the input sample rate
            y = convertFrom8kHz(plugin,z, fs);

            % Write to buffer
            write(plugin.buffer,y(:,1:size(in,2)));

            % Return output (same length as input)
            frameLength = size(in,1);
            out = cast(read(plugin.buffer,frameLength),dt);

        end

       function s = saveobj(obj)
            s = saveobj@audioPlugin(obj);
            s.stf = matlab.System.saveObject(obj.stf);
            s.istf = matlab.System.saveObject(obj.istf);
            s.segmentBuffer =  matlab.System.saveObject(obj.segmentBuffer);
            s.bufferOut =  matlab.System.saveObject(obj.bufferOut);
            s.bufferNN =  matlab.System.saveObject(obj.bufferNN);
            s.buffer =  matlab.System.saveObject(obj.buffer);
            s.ng =  matlab.System.saveObject(obj.ng);
            s.BypassNoiseGate = obj.BypassNoiseGate;
            s.Threshold = obj.Threshold;
            s.AttackTime = obj.AttackTime;
            s.ReleaseTime = obj.ReleaseTime;
            s.HoldTime = obj.HoldTime;
                    
            s.src16To8 = matlab.System.saveObject(obj.src16To8);
            s.src441To8 = matlab.System.saveObject(obj.src441To8);
            s.src48To8 = matlab.System.saveObject(obj.src48To8);
            s.src96To8 = matlab.System.saveObject(obj.src96To8);
            s.src192To8 = matlab.System.saveObject(obj.src192To8);
            s.src32To8 = matlab.System.saveObject(obj.src32To8);
            s.buffTo8 = matlab.System.saveObject(obj.buffTo8);

            s.src16From8 = matlab.System.saveObject(obj.src16From8);
            s.src441From8 = matlab.System.saveObject(obj.src441From8);
            s.src48From8 = matlab.System.saveObject(obj.src48From8);
            s.src96From8 = matlab.System.saveObject(obj.src96From8);
            s.src192From8 = matlab.System.saveObject(obj.src192From8);
            s.src32From8 = matlab.System.saveObject(obj.src32From8);
            s.buffFrom8 = matlab.System.saveObject(obj.buffFrom8);
        end
        function obj = reload(obj,s)
            obj = reload@audioPlugin(obj,s);
            obj.stf = matlab.System.loadObject(s.stf);
            obj.istf = matlab.System.loadObject(s.istf);
            obj.segmentBuffer = matlab.System.loadObject(s.segmentBuffer);
            obj.bufferOut = matlab.System.loadObject(s.bufferOut);
            obj.segmentBuffer = matlab.System.loadObject(s.segmentBuffer);
            obj.bufferNN = matlab.System.loadObject(s.bufferNN);
            obj.buffer = matlab.System.loadObject(s.buffer);
            obj.ng = matlab.System.loadObject(s.ng);
            obj.BypassNoiseGate = s.BypassNoiseGate;
            obj.Threshold = s.Threshold;
            obj.AttackTime = s.AttackTime;
            obj.ReleaseTime = s.ReleaseTime;
            obj.HoldTime = s.HoldTime;

            obj.src16To8 = matlab.System.loadObject(s.src16To8);
            obj.src441To8 = matlab.System.loadObject(s.src441To8);
            obj.src48To8 = matlab.System.loadObject(s.src48To8);
            obj.src96To8 = matlab.System.loadObject(s.src96To8);
            obj.src192To8 = matlab.System.loadObject(s.src192To8);
            obj.src32To8 = matlab.System.loadObject(s.src32To8);
            obj.buffTo8 = matlab.System.loadObject(s.buffTo8);

            obj.src16To8 = matlab.System.loadObject(s.src16To8);
            obj.src441To8 = matlab.System.loadObject(s.src441To8);
            obj.src48To8 = matlab.System.loadObject(s.src48To8);
            obj.src96To8 = matlab.System.loadObject(s.src96To8);
            obj.src192To8 = matlab.System.loadObject(s.src192To8);
            obj.src32To8 = matlab.System.loadObject(s.src32To8);
            obj.buffTo8 = matlab.System.loadObject(s.buffTo8);
        end

    end

    methods (Access=protected)
        function y = convertTo8kHz(plugin,in, fs)
            % convertFrom8kHz Convert signal x from Fs to 8 kHz

            % Buffer input audio frame
            write(plugin.buffTo8, in);

            % The length of the input to the sample-rate converter must be
            % a multiple of the decimation factor
            frameLength = size(in,1);
            N = getSRCFrameLength(frameLength,fs);
            numSamples = double(plugin.buffTo8.NumUnreadSamples);
            L = floor(numSamples/N);
            if L>0
                toRead = L*N;
                x = read(plugin.buffTo8, toRead);
            else
                x = zeros(N,size(in,2),'like',in);
            end

            switch fs
                case {8000}
                    y = x;
                case {16000}
                    L = floor(length(x)/2);
                    z = x(1:L*2,:);
                    y = plugin.src16To8(z);
                case {44100}
                    % Keep the frame rate constant
                    L = size(x,1)/441;
                    y = zeros(L*80,size(x,2),'like',x);
                    for index=1:L
                        frame = x((index-1)*441+1:441*index,1:size(x,2));
                        y((index-1)*80+1:80*index,:) = plugin.src441To8(frame(1:441,:));
                    end
                case {48000}
                    L = floor(length(x)/6);
                    z = x(1:L*6,:);
                    y = plugin.src48To8(z);
                case {96000}
                    L = floor(length(x)/12);
                    z = x(1:L*12,:);
                    y = plugin.src96To8(z);
                case {192000}
                    L = floor(length(x)/24);
                    z = x(1:L*24,:);
                    y = plugin.src192To8(z);
                case {32000}
                    L = floor(length(x)/4);
                    z = x(1:L*4,:);
                    y = plugin.src32To8(z);
                otherwise
                    y = x;
            end
        end

        function y = convertFrom8kHz(plugin,in, fs)
            % convertFrom8kHz Convert signal x from 8 kHz to Fs

            write(plugin.buffFrom8,in);

            % The length of the input to the sample-rate converter must be
            % a multiple of the decimation factor
            numSamples = double(plugin.buffFrom8.NumUnreadSamples);
            if fs==44100
                toRead = floor(numSamples/80)*80;
            else
                toRead = numSamples;
            end
            x = read(plugin.buffFrom8,toRead);

            switch fs
                case {8000}
                    y = x;
                case {16000}
                    y = plugin.src16From8(x);
                case {44100}
                    % Keep the frame length constant
                    L = size(x,1)/80;
                    y = zeros(L*441,size(x,2),'like',x);
                    for index=1:L
                        frame = x((index-1)*80+1:80*index,:);
                        y((index-1)*441+1:441*index,:) = plugin.src441From8(frame(1:80,:));
                    end
                case {48000}
                    y = plugin.src48From8(x);
                case {96000}
                    y = plugin.src96From8(x);
                case {192000}
                    y = plugin.src192From8(x);
                case {32000}
                    y = plugin.src32From8(x);
                otherwise
                    y = x;
            end

        end
    end
    methods(Static)
        function obj = loadobj(s)
            if isstruct(s)
                obj = audiopluginexample.Denoiser;
                obj = reload(obj,s);
            end
        end
    end
end

function y = denoise(x)
% Denoise input frame

% Load the pre-trained network.
persistent trainedNet noisyMean noisyStd cleanMean cleanStd;
if isempty(trainedNet)
    trainedNet = coder.loadDeepLearningNetwork('denoisePluginNet.mat');
    % These values were obtained during the training phase
    noisyMean = 0.366273585513061;
    noisyStd = 0.990942481736140;
    cleanMean = 0.149715539310324;
    cleanStd = 0.733326354621890;
end

x = (x-noisyMean)/noisyStd;
y = predict(trainedNet,x);
y = y*cleanStd+cleanMean;

end

function N = getSRCFrameLength(L,fs)
switch fs
    case {8000}
        N = L;
    case {16000}
        N = 2;
    case {44100}
        N = 441;
    case {48000}
        N = 6;
    case {96000}
        N = 12;
    case {192000}
        N = 24;
    case {32000}
        N = 4;
    otherwise
        N = L;
end
end