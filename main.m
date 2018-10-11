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


windowsSize = fix(audioInfo.TotalSamples/n_windows)+max(d_b0,d_b1);

windowsVectors = zeros(n_windows,windowsSize);

samplesIndex = 1;
currentWindowN = 1;
while(samplesIndex <= audioInfo.TotalSamples)
    
    for windowSample = 1:(windowsSize-max(d_b0,d_b1))
       if(samplesIndex > audioInfo.TotalSamples)
          break;
       endif
       windowsVectors(currentWindowN,windowSample) = audioSamples(samplesIndex);
      samplesIndex++;
    endfor
    currentWindowN+=1;
 endwhile
 
v_ascii       = toascii (d_metadatos);

for asciiIndex =  1:length(v_ascii)
  currentLetter      = v_ascii(asciiIndex);
  currentLetterBits  = flip ( bitget (currentLetter, 7:-1:1));
  for letterBitsIndex = 1:length(currentLetterBits)
    allbitsVector(letterBitsIndex+(asciiIndex-1)*7) = currentLetterBits(letterBitsIndex);
   endfor
endfor

if(length(allbitsVector) > n_windows)
  printf("Se necesitan mas ventanas para procesar los metadatos\n");
  return;
endif

for bitIndex = 1:length(allbitsVector)
  
  if(allbitsVector(bitIndex) == 1)
    a = d_a1;
    b = d_b1;
  else
    a = d_a0;
    b = d_b0;
  endif
  for windowsSamples = (b+1):windowsSize
      windowsVectors(bitIndex,windowsSamples) = windowsVectors(bitIndex,windowsSamples)+a*windowsVectors(bitIndex,windowsSamples-b);
  endfor
endfor 

y_index = 1;

for windowIndex = 1:length(windowsVectors)
  for windowsSamples = 1:windowsSize
    y_n(y_index) = windowsVectors(windowIndex,windowsSamples);
    y_index++;
  endfor
endfor

audiowrite("output.wav",y_n,audioInfo.SampleRate,'BitsPerSample',audioInfo.BitsPerSample);