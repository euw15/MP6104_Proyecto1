clear;
clc;
%********************************************************
%**********   Extraccion de Audio        ****************
%********************************************************
[audioSamples,fs] = audioread("AudioSamples/pointless.wav");

audioInfo = audioinfo("AudioSamples/pointless.wav");

%*********************************************************
%**********   Enventadanado        ***********************
%*********************************************************
input_Windows = 'Numero de Ventanas ';
n_windows = input(input_Windows);

if(n_windows <= 0)
  printf("El numero de ventanas debe ser mayor a 0\n");
  return;
endif



%*********************************************************
%**************    Multiplexado  *************************
%*********************************************************
s_a0 = 'a0 ';
d_a0 = input(s_a0);

s_a1 = 'a1 ';
d_a1 = input(s_a1);

s_b0 = 'b0 ';
d_b0 = input(s_b0);

s_b1 = 'b1 ';
d_b1 = input(s_b1);

s_metadatos = 'Metadatos ';
d_metadatos = input(s_metadatos);
v_ascii     = toascii (d_metadatos);

windowsSize = audioInfo.TotalSamples/n_windows;

samplesIndex = 1;
while(samplesIndex <= audioInfo.TotalSamples)
    letterIndex  = fix(abs(samplesIndex-1)/7)+1;
  
  if(letterIndex > length(v_ascii))
    y_n(samplesIndex) = audioSamples(samplesIndex);
    samplesIndex++;
  else  
    currentLetter      = v_ascii(letterIndex);
    currentLetterBits  = flip ( bitget (currentLetter, 7:-1:1));
    currentBit         = currentLetterBits(mod((samplesIndex-1),7)+1);
    
    currentWindowIndex = mod(samplesIndex,n_windows);
    currentWindowN     = fix(abs(samplesIndex-1)/7)+1;
    
    if(currentBit)
      for windowSample = 1:windowsSize
          replicaSampleIndex = windowSample*currentWindowN-d_b0;
          
          if(windowSample*currentWindowN > audioInfo.TotalSamples)
            break;
          endif
          
          if(replicaSampleIndex < 1 ||   replicaSampleIndex >= audioInfo.TotalSamples)
            replicaSample = 0;
          else
            replicaSample = d_a0*audioSamples(replicaSampleIndex);
          endif
            y_n(samplesIndex) = audioSamples(windowSample*currentWindowN)+replicaSample;
            samplesIndex++;
            
      endfor
    else
      for windowSample = 1:windowsSize
          replicaSampleIndex = windowSample*currentWindowN-d_b1;
          
          if(windowSample*currentWindowN > audioInfo.TotalSamples)
            break;
          endif
          
          if(replicaSampleIndex < 1 ||   replicaSampleIndex >= audioInfo.TotalSamples)
            replicaSample = 0;
          else
            replicaSample = d_a1*audioSamples(replicaSampleIndex);
          endif
           y_n(samplesIndex) = audioSamples(windowSample*currentWindowN)+replicaSample;
           samplesIndex++;
            
      endfor
    endif
   endif
  
endwhile

audiowrite("output.wav",y_n,audioInfo.SampleRate,'BitsPerSample',audioInfo.BitsPerSample);


