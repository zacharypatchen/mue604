
classdef biquad < audioPlugin
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
            'Style','rotaryknob', ...
            'Mapping',{'log',2500,20000}),...
          audioPluginParameter('HS_GAIN',...
            'DisplayName','HI SHLF GAIN',...
            'Label', 'dB',...
            'Style','rotaryknob', ...
            'Mapping',{'lin',-12,12}),...
          audioPluginParameter('HMF_FREQ',...
            'DisplayName','HI-MID FREQ',...
            'Label', 'Hz',...
            'Style','rotaryknob', ...
            'Mapping',{'log',800,12500}),...
          audioPluginParameter('HMF_GAIN',...
            'DisplayName','HI-MID GAIN',...
            'Label', 'dB',...
            'Style','rotaryknob', ...
            'Mapping',{'lin',-12,12}),...
          audioPluginParameter('LMF_FREQ',...
            'DisplayName','LO-MID FREQ',...
            'Label', 'Hz',...
            'Style','rotaryknob', ...
            'Mapping',{'log',75,1000}),...
          audioPluginParameter('LMF_GAIN',...
            'DisplayName','LO-MID GAIN',...
            'Label', 'dB',...
            'Style','rotaryknob', ...
            'Mapping',{'lin',-12,12}),...
          audioPluginParameter('HPF_FREQ',...
            'DisplayName','DC BLK FREQ',...
            'Label', 'Hz',...
            'Style','rotaryknob', ...
            'Mapping',{'log',30,400}),...
          audioPluginParameter('BYPASS',...
            'DisplayName', 'Bypass',...
            'Style', 'vtoggle',...
            'Mapping',{'enum','engage','bypass'}));
    end
    properties (Access = private)
        filter_HS = struct('w', [0 0; 0 0], 'a0', 1, 'a1', 0, 'a2', 0, 'b0', 1, 'b1', 0, 'b2', 0);
        filter_HMF = struct('w', [0 0; 0 0], 'a0', 1, 'a1', 0, 'a2', 0, 'b0', 1, 'b1', 0, 'b2', 0);     
        filter_LMF = struct('w', [0 0; 0 0], 'a0', 1, 'a1', 0, 'a2', 0, 'b0', 1, 'b1', 0, 'b2', 0);
        filter_HPF = struct('w', [0 0; 0 0], 'a0', 1, 'a1', 0, 'a2', 0, 'b0', 1, 'b1', 0, 'b2', 0);

    end
    
    methods
        function out = process(plugin,in)
            
            out = zeros(size(in));
            
            for ch = 1:min(size(in))
       
                x = in(:,ch);
                
                [y1, plugin.filter_HS.w(:,ch)] = processBiquad(x, plugin.filter_HS, ch);
                [y2, plugin.filter_HMF.w(:,ch)] = processBiquad(y1, plugin.filter_HMF, ch);
                [y3, plugin.filter_LMF.w(:,ch)] = processBiquad(y2, plugin.filter_LMF, ch);
                [y4, plugin.filter_HPF.w(:,ch)] = processBiquad(y3, plugin.filter_HPF, ch);


                if strcmp(plugin.BYPASS,'bypass')
                    out(:,ch)= x;
                else
                    out(:,ch) = y4; 
                end

            end
            
        end
        
        function reset(plugin)
            %{
            import matlab.net.*
            import matlab.net.http.*
            

            
            prompt1='I have an audio Equalizer that comprises a high-pass filter in addition to two parametric bell bands, each with variable frequency and gain or attenuation, and finally a high shelf band with variable frequency and gain. Generate parameter settings to create a sound that is ';
            prompt2='loud and punchy';
            prompt3='. Code the parameter values into MATLAB variables. Do not give any additional explanation, only include the code. Give the frequency values in Hz and the gain values in dB. Use the following variable names: high-pass filter cutoff frequency is HPF_FREQ, the lowest band frequency variable LMF_FREQ and its gain is LMF_GAIN, the middle band frequency variable is HMF_FREQ and its gain is HMF_GAIN, and the highest band variable name for frequency is HS_FREQ and its gain name is HS_GAIN.';
            prompt=[prompt1 prompt2 prompt3];  
            
            parameters = struct('prompt',prompt, 'model','text-davinci-003', 'max_tokens',100);
            headers = matlab.net.http.HeaderField('Content-Type', 'application/json');
            headers(2) = matlab.net.http.HeaderField('Authorization', ['Bearer ' api_key]);
            request = matlab.net.http.RequestMessage('post',headers,parameters);
            
            response = send(request, matlab.net.URI(api_endpoint));
            response_text = response.Body.Data;
            response_text = response_text.choices(1).text;
            disp(response_text);
            eval(response_text);
            %}
            
            %set.HS_FREQ(plugin, HS_FREQ);
            %set.HS_GAIN(plugin, HS_GAIN);
            %set.HMF_FREQ(plugin, HMF_FREQ);
            %set.HMF_GAIN(plugin, HMF_GAIN);
            %set.LMF_FREQ(plugin, LMF_FREQ);
            %set.LMF_GAIN(plugin, LMF_GAIN);
            %set.HPF_FREQ(plugin, HPF_FREQ);

            
            
            %%%%%%%%%%%%%%
            plugin.fs = getSampleRate(plugin);
            plugin.fn = plugin.fs/2;
            
            plugin.filter_HS.w = [0 0; 0 0];

            plugin.filter_HMF.w = [0 0; 0 0];
 
            plugin.filter_LMF.w = [0 0; 0 0];

            plugin.filter_HPF.w = [0 0; 0 0];
            
        end
        
        function set.HS_FREQ(plugin, val)
            plugin.HS_FREQ = val;
            update_HS(plugin);
        end
        
        function set.HS_GAIN(plugin, val)
            plugin.HS_GAIN = val;
            update_HS(plugin);
        end
        
        function update_HS(plugin)
            Q=0.5;
            f0=plugin.HS_FREQ;
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
            update_HMF(plugin);
        end
        
        function set.HMF_GAIN(plugin, val)
            plugin.HMF_GAIN = val;
            update_HMF(plugin);
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
            update_LMF(plugin);
        end
        
        function set.LMF_GAIN(plugin, val)
            plugin.LMF_GAIN = val;
            update_LMF(plugin);
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
            update_HPF(plugin);
            
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