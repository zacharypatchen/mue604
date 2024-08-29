classdef biquad < audioPlugin
    %{
INSTRUCTIONS:
1. add a GUI layout with Matlab controls or filmstrip controls
2. replace the 'filter' command with your own DSP code in processBiquad.m
3. add a Q setting to each of these filters
4. use a parameter ramper to make the controls smooth
5. Export to a JUCE project, and compile a VST3 or AU
6. [ENGAGE] Demonstrate your filter inserted on an audio track
    %}

    properties
        HS_FREQ = 10000;      
        HS_GAIN = 0;
        
        HMF_FREQ = 5000;
        HMF_GAIN = 0;
        
        LMF_FREQ = 500;
        LMF_GAIN = 0;
        
        HPF_FREQ = 50;
        
        fs = 44100;
        fn=22050;
        
        BYPASS = 'engage';
        
    end
    properties (Constant)
        PluginInterface = audioPluginInterface(...
          audioPluginParameter('HS_FREQ',...
            'DisplayName','HI SHLF FREQ',...
            'Label', 'Hz',...
            'Mapping',{'log',2500,20000}),...
          audioPluginParameter('HS_GAIN',...
            'DisplayName','HI SHLF GAIN',...
            'Label', 'dB',...
            'Mapping',{'lin',-12,12}),...
          audioPluginParameter('HMF_FREQ',...
            'DisplayName','HI-MID FREQ',...
            'Label', 'Hz',...
            'Mapping',{'log',800,12500}),...
          audioPluginParameter('HMF_GAIN',...
            'DisplayName','HI-MID GAIN',...
            'Label', 'dB',...
            'Mapping',{'lin',-12,12}),...
          audioPluginParameter('LMF_FREQ',...
            'DisplayName','LO-MID FREQ',...
            'Label', 'Hz',...
            'Mapping',{'log',75,1000}),...
          audioPluginParameter('LMF_GAIN',...
            'DisplayName','LO-MID GAIN',...
            'Label', 'dB',...
            'Mapping',{'lin',-12,12}),...
          audioPluginParameter('HPF_FREQ',...
            'DisplayName','DC BLK FREQ',...
            'Label', 'Hz',...
            'Mapping',{'log',30,400}),...
          audioPluginParameter('BYPASS',...
            'DisplayName', 'Bypass',...
            'Mapping',{'enum','engage','bypass'}));
    end

    properties (Access = private)
        filter_HS = struct('w', [0 0; 0 0], 'a0', 1, 'a1', 0, 'a2', 0, 'b0', 1, 'b1', 0, 'b2', 0);
        filter_HMF = struct('w', [0 0; 0 0], 'a0', 1, 'a1', 0, 'a2', 0, 'b0', 1, 'b1', 0, 'b2', 0);     
        filter_LMF = struct('w', [0 0; 0 0], 'a0', 1, 'a1', 0, 'a2', 0, 'b0', 1, 'b1', 0, 'b2', 0);
        filter_HPF = struct('w', [0 0; 0 0], 'a0', 1, 'a1', 0, 'a2', 0, 'b0', 1, 'b1', 0, 'b2', 0);

        % parameter smoothers
        hsFreqSmoother

    end
    
    methods
        function plugin = biquad()
            % Initialize smoothers with default values
            plugin.hsFreqSmoother = ParameterSmoother(plugin.HS_FREQ, 0.9);

        end

        function out = process(plugin,in)
            
            out = zeros(size(in));

             % Smooth values
            update_HMF(plugin);
            update_LMF(plugin);
            update_HPF(plugin);
            update_HS(plugin);
            
            for ch = 1:min(size(in))
       
                x = in(:,ch);
                
                [x, plugin.filter_HS.w(:,ch)] = processBiquad(x, plugin.filter_HS, ch);
                [x, plugin.filter_HMF.w(:,ch)] = processBiquad(x, plugin.filter_HMF, ch);
                [x, plugin.filter_LMF.w(:,ch)] = processBiquad(x, plugin.filter_LMF, ch);
                [x, plugin.filter_HPF.w(:,ch)] = processBiquad(x, plugin.filter_HPF, ch);


                if strcmp(plugin.BYPASS,'bypass')
                    out(:,ch)= in(:,ch);
                else
                    out(:,ch) = x; 
                end

            end
            
        end
        
        function reset(plugin)
            
            plugin.fs = getSampleRate(plugin);
            plugin.fn = plugin.fs/2;
            
            plugin.filter_HS.w = [0 0; 0 0];

            plugin.filter_HMF.w = [0 0; 0 0];
 
            plugin.filter_LMF.w = [0 0; 0 0];

            plugin.filter_HPF.w = [0 0; 0 0];
            
        end
        
        function set.HS_FREQ(plugin, val)
            plugin.HS_FREQ = val;
            plugin.hsFreqSmoother.setTargetValue(val);
        end
        
        function set.HS_GAIN(plugin, val)
            plugin.HS_GAIN = val;
 
        end
        
        function update_HS(plugin)
            f0 = plugin.hsFreqSmoother.step();

            Q=0.5;
         %   f0=plugin.HS_FREQ;
            gain = plugin.HS_GAIN;
            w0=2*pi*f0/plugin.fs;
            alpha=sin(w0)/(2*Q);
            A=sqrt(db2mag(gain));
            
            plugin.filter_HS.a0 =    A*( (A+1) + (A-1)*cos(w0) + 2*sqrt(A)*alpha );
            plugin.filter_HS.a1 = -2*A*( (A-1) + (A+1)*cos(w0)                   );
            plugin.filter_HS.a2 =    A*( (A+1) + (A-1)*cos(w0) - 2*sqrt(A)*alpha );
            plugin.filter_HS.b0 =        (A+1) - (A-1)*cos(w0) + 2*sqrt(A)*alpha;
            plugin.filter_HS.b1 =    2*( (A-1) - (A+1)*cos(w0)                   );
            plugin.filter_HS.b2 =        (A+1) - (A-1)*cos(w0) - 2*sqrt(A)*alpha;
            
        end
        

        
        function set.HMF_FREQ(plugin, val)
            plugin.HMF_FREQ = val;

        end
        
        function set.HMF_GAIN(plugin, val)
            plugin.HMF_GAIN = val;

        end
        
        function update_HMF(plugin)

            Q=0.5;
            f0=plugin.HMF_FREQ;
            gain = plugin.HMF_GAIN;
            w0=2*pi*f0/plugin.fs;
            alpha=sin(w0)/(2*Q);
            A=sqrt(db2mag(gain));
            
            plugin.filter_HMF.a0 =   1 + alpha*A;
            plugin.filter_HMF.a1 =  -2*cos(w0);
            plugin.filter_HMF.a2 =   1 - alpha*A;
            plugin.filter_HMF.b0 =   1 + alpha/A;
            plugin.filter_HMF.b1 =  -2*cos(w0);
            plugin.filter_HMF.b2 =   1 - alpha/A;
        end
        
        
        
        function set.LMF_FREQ(plugin, val)
            plugin.LMF_FREQ = val;

        end
        
        function set.LMF_GAIN(plugin, val)
            plugin.LMF_GAIN = val;

        end
        
        function update_LMF(plugin)

            Q=0.5;
            f0=plugin.LMF_FREQ;
            gain = plugin.LMF_GAIN;
            w0=2*pi*f0/plugin.fs;
            alpha=sin(w0)/(2*Q);
            A=sqrt(db2mag(gain));
            
            plugin.filter_LMF.a0 =   1 + alpha*A;
            plugin.filter_LMF.a1 =  -2*cos(w0);
            plugin.filter_LMF.a2 =   1 - alpha*A;
            plugin.filter_LMF.b0 =   1 + alpha/A;
            plugin.filter_LMF.b1 =  -2*cos(w0);
            plugin.filter_LMF.b2 =   1 - alpha/A;
        end
        
        
        function set.HPF_FREQ(plugin, val)
            plugin.HPF_FREQ = val;

            
        end


        function update_HPF(plugin)


            f0=plugin.HPF_FREQ;
            Q = 0.5;
            w0=2*pi*f0/plugin.fs;
            alpha=sin(w0)/(2*Q);

            
            plugin.filter_HPF.a0 =  (1 + cos(w0))/2;
            plugin.filter_HPF.a1 = -(1 + cos(w0));
            plugin.filter_HPF.a2 =  (1 + cos(w0))/2;
            plugin.filter_HPF.b0 =   1 + alpha;
            plugin.filter_HPF.b1 =  -2*cos(w0);
            plugin.filter_HPF.b2 =   1 - alpha;
        end
        
        function set.BYPASS(plugin, val)
            plugin.BYPASS = val;
        end
        
    end
end