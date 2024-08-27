classdef tonestack < audioPlugin
    properties
        BASS = 0;
        TREB = 0;
        Tonestack=OperatingMode.Portaflex;
        Engage = true;
  
    end
    properties (Constant)
        PluginInterface = audioPluginInterface(...
            'PluginName', 'JamesToneStack',...
            'VendorName', 'DigitalAudioTheory',...
            'UniqueId', 'DATj',...
        audioPluginGridLayout( ...
            'RowHeight',[25,25,25,25,25,25,25,25,25,25,230], ...
            'ColumnWidth',[150,150,110]),...
        audioPluginParameter('Tonestack',...
            'Style', 'dropdown',...
            'DisplayNameLocation','none',...
            'Layout',[10, 3]),...
        audioPluginParameter('Engage', ...
            'Mapping', {'enum','On','Off'}, ...
            'Layout',[7,3; 9,3], ...
            'Filmstrip', 'switch_toggle.png',...
            'FilmstripFrameSize', [56 56],...
            'DisplayNameLocation','none'),... 
        audioPluginParameter('BASS',...
            'DisplayName','Bass',...
            'Label', 'dB',...
            'Filmstrip', 'dial.png',...
            'FilmstripFrameSize', [95 95],...
            'Style', 'rotaryknob',...
            'Layout', [7,1; 10,1],...
            'DisplayNameLocation','above',...
            'Mapping',{'lin',-18,18}),...
        audioPluginParameter('TREB',...
            'DisplayName','Treble',...
            'Label', 'dB',...
            'Filmstrip', 'dial.png',...
            'FilmstripFrameSize', [95 95],...
            'Style', 'rotaryknob',...
            'DisplayNameLocation','above',...
            'Layout', [7,2; 10,2],...
            'Mapping',{'lin',-18,18}),...
            ...
            'BackgroundColor',[0.3 0.3 0.3],...
            'BackgroundImage', 'bg.png');
        
        %{
        audioPluginParameter('C1',...
            'Label', 'nF',...
            'Style', 'rotaryknob',...
            'Layout', [7,4],...
            'DisplayNameLocation','right',...
            'EditBoxLocation', 'left',...
            'Mapping',{'log',0.01,10}),...
        audioPluginParameter('C4',...
            'Label', 'nF',...
            'Style', 'rotaryknob',...
            'Layout', [5,4],...
            'DisplayNameLocation','right',...
            'EditBoxLocation', 'left',...
            'Mapping',{'log',1,200}),...
        audioPluginParameter('RT',...
            'Label', 'kOhm',...
            'Style', 'rotaryknob',...
            'Layout', [8,4],...
            'DisplayNameLocation','right',...
            'EditBoxLocation', 'left',...
            'Mapping',{'log',40,4000}),...
        audioPluginParameter('RB',...
            'Label', 'kOhm',...
            'Style', 'rotaryknob',...
            'Layout', [2,4],...
            'DisplayNameLocation','right',...
            'EditBoxLocation', 'left',...
            'Mapping',{'log',10,1000}),...
        audioPluginParameter('R2',...
            'Label', 'kOhm',...
            'Style', 'rotaryknob',...
            'Layout', [3,4],...
            'DisplayNameLocation','right',...
            'EditBoxLocation', 'left',...
            'Mapping',{'log',0.1,200}),...
        audioPluginParameter('R3',...
            'Label', 'kOhm',...
            'Style', 'rotaryknob',...
            'Layout', [6,4],...
            'DisplayNameLocation','right',...
            'EditBoxLocation', 'left',...
            'Mapping',{'log',1,220}),...
        audioPluginParameter('R1',...
            'Label', 'kOhm',...
            'Style', 'rotaryknob',...
            'Layout', [1,4],...
            'DisplayNameLocation','right',...
            'EditBoxLocation', 'left',...
            'Mapping',{'log',1,500}),...
        audioPluginParameter('C3',...
            'Label', 'nF',...
            'Style', 'rotaryknob',...
            'Layout', [4,4],...
            'DisplayNameLocation','right',...
            'EditBoxLocation', 'left',...
            'Mapping',{'log',0.1,10}),...
        audioPluginParameter('C2',...
            'Label', 'nF',...
            'Style', 'rotaryknob',...
            'Layout', [9,4],...
            'DisplayNameLocation','right',...
            'EditBoxLocation', 'left',...
            'Mapping',{'log',0.1,100}),...
            %}
    end
    properties (Access = private)
        
        a1_set = [1;0;0];
        b1_set = [1;0;0];
        a2_set = [1;0;0];
        b2_set = [1;0;0];
        
        a1_val = [1;0;0];
        b1_val = [1;0;0];
        a2_val = [1;0;0];
        b2_val = [1;0;0];
        
        Z_SOS1=[0 0; 0 0];
        Z_SOS2=[0 0; 0 0];
        
        C1 = 0.047;
        C2 = 0.47;
        C3 = 1;
        C4 = 10;
        R1 = 220;
        R2 = 22;
        R3  = 120;
        RT = 1000;
        RB = 1000;
        gain=11.13;
        
        
    end
    methods
        function out = process(plugin,in)
            
            % pre-size buffers
            out = zeros(size(in));
            x = zeros(length(in), 1);
            th=1e-5;
            div=20;
            
            a1_step = (plugin.a1_set-plugin.a1_val)/div;
            if any(abs(a1_step)>th)
                
                plugin.a1_val = a1_step+plugin.a1_val;
            else
                plugin.a1_val = plugin.a1_set;
            end
            
            b1_step = (plugin.b1_set-plugin.b1_val)/div;
            if any(abs(b1_step)>th)
                plugin.b1_val = b1_step+plugin.b1_val;
            else
                plugin.b1_val = plugin.b1_set;
            end
            
            a2_step = (plugin.a2_set-plugin.a2_val)/div;
            if any(abs(a2_step)>th)
                plugin.a2_val = a2_step+plugin.a2_val;
            else
                plugin.a2_val = plugin.a2_set;
            end
            
            b2_step = (plugin.b2_set-plugin.b2_val)/div;
            if (abs(b2_step)>th)
                plugin.b2_val = b2_step+plugin.b2_val;
            else
                plugin.b2_val = plugin.b2_set;
            end
            
            
            
            for ch = 1:min(size(in))
                
                x = in(:,ch);
                
                [y1, plugin.Z_SOS1(:,ch)] = filter(plugin.a1_val, plugin.b1_val, x, plugin.Z_SOS1(:,ch));
                
                [y2, plugin.Z_SOS2(:,ch)] = filter(plugin.a2_val, plugin.b2_val, y1, plugin.Z_SOS2(:,ch));
                
                if plugin.Engage
                    out(:,ch) = y2;
                else
                    out(:,ch)=x;
                end
                
            end
            
        end
        
        function reset(plugin)
            %Z = [0 0];
            %plugin.Z_SOS1 = [Z' Z'];
            %plugin.Z_SOS2 = [Z' Z'];
            
            updateFilterCoeffs(plugin);
        end
        
        function updateFilterCoeffs(plugin)
            C1 = plugin.C1*1e-9;
            C2 = plugin.C2*1e-9;
            C3 = plugin.C3*1e-9;
            C4 = plugin.C4*1e-9;
            RT = plugin.RT*1e3;
            RB = plugin.RB*1e3;
            R1 = plugin.R1*1e3;
            R2 = plugin.R2*1e3;
            R3 = plugin.R3*1e3;
            gain = plugin.gain;
            
            [num4, den4] = solveJamesCoeffs(plugin.BASS, plugin.TREB, C1,C2,R1,C3,R2,C4,R3,RT,RB);
            
            [plugin.a1_set, plugin.b1_set, plugin.a2_set, plugin.b2_set] = baxandall(num4, den4, getSampleRate(plugin), gain);
            
        end
        
        function set.Engage(plugin, val)
            plugin.Engage = val;
            updateFilterCoeffs(plugin);
        end
        function out = get.Engage(plugin)
            out = plugin.Engage;
        end
        
        function set.BASS(plugin, val)
            plugin.BASS = val;
            updateFilterCoeffs(plugin);
        end
        function out = get.BASS(plugin)
            out = plugin.BASS;
        end
        
        function set.TREB(plugin, val)
            plugin.TREB = val;
            updateFilterCoeffs(plugin);
        end
        function out = get.TREB(plugin)
            out = plugin.TREB;
        end
        
       
        
        function set.Tonestack(plugin, val)
            plugin.Tonestack = val;
            
            switch plugin.Tonestack
                
                case OperatingMode.Bass
                    % https://www.infineon.com/dgdl/Infineon-Demoboard_DEMO_BASSAMP_60W_MA12070-ApplicationNotes-v01_00-EN.pdf?fileId=5546d46272e49d2a017351e1a4545964
                    % Bass Amp - c/o 150 hz
                    plugin.C1=(2.2);
                    plugin.C2=(22);
                    plugin.C3=(4.7);
                    plugin.C4=(47);
                    plugin.R1=(47);
                    plugin.R2=(4.7);
                    plugin.R3=(33);
                    plugin.RT=(250);
                    plugin.RB=(250);
                    plugin.gain = 10.5;


                case OperatingMode.Orange
                    %Orange MK II - thin - c/o 150 hz
                    %kbapps.com graphicmkII120W.php
                    plugin.C1 = 1.5;
                    plugin.C2 = 10;
                    plugin.C3 = 2.2;
                    plugin.C4 = 22;
                    plugin.R1 = 100;
                    plugin.R2 = 22;
                    plugin.R3  = 100;
                    plugin.RT = 1000;
                    plugin.RB = 1000;
                    plugin.gain = 8.35;

                case OperatingMode.Bax52
                    % passive bax WW - bright - c/o 700 hz
                    plugin.C1 = .33;
                    plugin.C2 = 3.3;
                    plugin.C3 = .47;
                    plugin.C4 = 4.7;
                    plugin.R1 = 100;
                    plugin.R2 = 10;
                    plugin.R3  = 180;
                    plugin.RT = 500;
                    plugin.RB = 500;
                    plugin.gain = 10.15;

                case OperatingMode.Portaflex
                    % Ampeg "portaflex" ... B15-NF - nice, c/0 1k
                    % thetubestore.com ampeg-bn15nf-portaflex-amp-schematic.pdf
                    plugin.C1 = 0.047;
                    plugin.C2 = 0.47;
                    plugin.C3 = 1;
                    plugin.C4 = 10;
                    plugin.R1 = 220;
                    plugin.R2 = 22;
                    plugin.R3  = 120;
                    plugin.RT = 1000;
                    plugin.RB = 1000;
                    plugin.gain = 11.13;

                case OperatingMode.Gemini
                    % Ampeg "Gemini" G-12 and GS-15R: beautiful!
                    % https://drtube.com/schematics/ampeg/g12-jp.gif
                    plugin.C1 = .047;
                    plugin.C2 = .47;
                    plugin.C3 = 1;
                    plugin.C4 = 10;
                    plugin.R1 = 220;
                    plugin.R2 = 22;
                    plugin.R3  = 120;
                    plugin.RT = 4000;
                    plugin.RB = 1000;
                    plugin.gain = 11.1;

                case OperatingMode.GVT
                    % Ampeg GVT-5 - decent, cutoff around 500 Hz
                    plugin.C1 = .47;
                    plugin.C2 = 4.7;
                    plugin.C3 = 1;
                    plugin.C4 = 10;
                    plugin.R1 = 220;
                    plugin.R2 = 22;
                    plugin.R3  = 47;
                    plugin.RT = 1000;
                    plugin.RB = 1000;
                    plugin.gain = 10.27;

                case OperatingMode.Magnatone
                    % Magnatone 260
                    % https://elektrotanya.com/PREVIEWS/63463243/23432455/magnatone/magnatone_260-a.pdf_1.png
                    plugin.C1 = 0.47;
                    plugin.C2 = 4.7;
                    plugin.C3 = .47;
                    plugin.C4 = 4.7;
                    plugin.R1 = 330;
                    plugin.R2 = 47;
                    plugin.R3  = 120;
                    plugin.RT = 1000;
                    plugin.RB = 1000;
                    plugin.gain = 9.37;

                case OperatingMode.Duncans
                    % Duncan's Blues - good, c/o 650 hz
                    plugin.C1 = 0.33;
                    plugin.C2 = 3.3;
                    plugin.C3 = .47;
                    plugin.C4 = 4.7;
                    plugin.R1 = 100;
                    plugin.R2 = 10;
                    plugin.R3  = 180;
                    plugin.RT = 1000;
                    plugin.RB = 1000;
                    plugin.gain = 9.7;

                case OperatingMode.Bennetts
                    plugin.C1 = 6.8;
                    plugin.C2 = 33;
                    plugin.C3 = 10;
                    plugin.C4 = 100;
                    plugin.R1 = 12;
                    plugin.R2 = 1.2;
                    plugin.R3  = 3.3;
                    plugin.RT = 47;
                    plugin.RB = 47;
                    plugin.gain = 8.35;

            end
            updateFilterCoeffs(plugin);
        end
        
         
        
    end
end