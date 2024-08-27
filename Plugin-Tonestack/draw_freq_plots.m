clf
FS=44100;

for val=0:8
    
    switch val
        
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
            name='Bass Amp';
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
            name='Orange';
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
            name='Baxandall';
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
            name='Portaflex';
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
            name='Gemini';
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
            name='GVT';
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
            name='Magnatone';
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
            name='Duncan DDS';
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
            name='Bennett (DAT)';
    end
    
    %%

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
    
    subplot(2,5,val+1)
    
    for lvl=-12:3:12
        [num4, den4] = solveJamesCoeffs(lvl, -lvl, C1,C2,R1,C3,R2,C4,R3,RT,RB);
        
        [num1,den1,num2,den2] = baxandall(num4, den4, FS, gain);
        
        W=20:20000;
        H=freqs(num4,den4,W);
        
        [H1,W1]=freqz(num1,den1, FS,FS);
        [H2,W2]=freqz(num2,den2, FS,FS);
        
        hold on
        semilogx(W1, db(abs(H1.*H2)));
        %semilogx(W,db(8.35*abs(H)));
    end
    set(gca,'xscale','log')
    axis([20 20000 -12 12])
    grid on
    box on
    %ylabel('Level (dB)')
    %xlabel('Freq (kHz)')
    title(name,'Color',[1 1 1])
    set(gca,'FontSize',14, 'XColor', 'white','YColor', 'white', 'color',[0.3 0.3 0.3])
end

set(gcf,'color','black')