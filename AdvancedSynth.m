classdef AdvancedSynth < audioPluginSource

    
    properties
        GainDB = 1;
    end
    properties (Access = private)
        GainMemory = 1;
        GainLinear = 1;
    end
    properties (Constant)
        PluginInterface = audioPluginInterface(...
            'PluginName', 'Advanced Synth',...
            'VendorName', 'Digital Audio Theory',...
            'VendorVersion', '1.0.0gen',...
            'UniqueId', 'DATs',...
            'BackgroundColor', [0.4157    0.7765    0.9333],...
            audioPluginParameter('GainDB',...
                'DisplayName', 'Damped Gain',...
                'Label', 'dB',...
                'Mapping', {'pow',1/3,-60,20}));
    end
    methods
        function out = process(plugin)
            noise = randn(getSamplesPerFrame(plugin),2);
            gain=0.5*(plugin.GainLinear+plugin.GainMemory);
            out=noise*gain;
            plugin.GainMemory=gain;
        end
        function reset(plugin)
            plugin.GainMemory=1;
        end
        function set.GainDB(plugin, val)
            plugin.GainDB=val;
            plugin.GainLinear=10^(val/20);
        end
    end
end