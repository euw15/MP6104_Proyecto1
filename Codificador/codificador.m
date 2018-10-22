clear;
clc;
%********************************************************
%**********   Constantes        *************************
%********************************************************

bitsPerChar = 7;

%********************************************************
%**********   Extraccion de Audio        ****************
%********************************************************
[file, path] = uigetfile ('*.wav',"Seleccione archivo de audio");
if isequal(file,0)
   disp('Archivo invalido');
else
   disp(['Archivo: ', fullfile(path,file)]);
end

[audioSamples,fs] = audioread(fullfile(path,file));

audioInfo         = audioinfo(fullfile(path,file));

%*********************************************************
%**************  Parametros de entrada  ******************
%*********************************************************
input_Windows = 'Numero de Ventanas ';
n_windows     = input(input_Windows);

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

%*********************************************************
%**************  Verificacion de Entradas  ***************
%*********************************************************
if(n_windows <= 0)
  printf("El numero de ventanas debe ser mayor a 0\n");
  return;
endif

if(bitsPerChar >= n_windows)
  printf("Se necesitan mas ventanas para representar un char\n");
  return;
endif

if(n_windows >= audioInfo.TotalSamples)
  printf("Mas ventanas que muestras\n");
  return;
endif

if(d_b0 <= 0 || d_b1 <= 0)
  printf("d debe ser mayor que cero\n");
  return;
endif

%*********************************************************
%**********   Enventadanado        ***********************
%*********************************************************
windowsSize    = fix(audioInfo.TotalSamples/n_windows)+max(d_b0,d_b1);

windowsVectors = zeros(n_windows,windowsSize);

samplesIndex   = 1;
currentWindowN = 1;

while(samplesIndex <= audioInfo.TotalSamples)
    
    for windowSample = 1:fix(audioInfo.TotalSamples/n_windows)
       if(samplesIndex > audioInfo.TotalSamples)
          break;
       endif
       windowsVectors(currentWindowN,windowSample) = audioSamples(samplesIndex);
      samplesIndex++;
    endfor
    currentWindowN+=1;
 endwhile
 
%*********************************************************
%**********   Metadatos to bits        *******************
%*********************************************************
 v_ascii       = toascii (d_metadatos);

for asciiIndex =  1:length(v_ascii)
  currentLetter      = v_ascii(asciiIndex);
  currentLetterBits  = flip ( bitget (currentLetter, bitsPerChar:-1:1));
  for letterBitsIndex = 1:length(currentLetterBits)
    allbitsVector(letterBitsIndex+(asciiIndex-1)*bitsPerChar) = currentLetterBits(letterBitsIndex);
   endfor
endfor

if(length(allbitsVector) > n_windows)
  printf("Se necesitan mas ventanas para procesar los metadatos\n");
  return;
endif

%*********************************************************
%**********   Multiplexado y convolucion******************
%*********************************************************
for bitIndex = 1:length(allbitsVector)
  
  if(allbitsVector(bitIndex) == 1)
    a = d_a1;
    b = d_b1;
  else
    a = d_a0;
    b = d_b0;
    c = d_b1-d_b0;
  endif
  for windowsSamples = (b+1):fix(audioInfo.TotalSamples/n_windows)+b
      windowsVectors(bitIndex,windowsSamples) = windowsVectors(bitIndex,windowsSamples)+a*windowsVectors(bitIndex,windowsSamples-b);
  endfor
endfor 

%*********************************************************
%**********   Combinacion    *****************************
%*********************************************************
y_index = 1;

for(i = 1:audioInfo.TotalSamples)
 y_n(i) = 0;
endfor


 b = max(d_b0,d_b1);
 
for windowIndex = 1:currentWindowN-1
  if(windowIndex == 1)
    y_index-=0;
  else
    y_index-=b;
  endif
  for windowsSamples = 1:fix(audioInfo.TotalSamples/n_windows)+b
    if(y_index > audioInfo.TotalSamples)
      break;
    endif
    y_n(y_index) += windowsVectors(windowIndex,windowsSamples);
    y_index++;
  endfor
endfor



%*********************************************************
%**********   Escritura Audio    *****************************
%*********************************************************
audiowrite("output.wav",y_n,audioInfo.SampleRate,'BitsPerSample',audioInfo.BitsPerSample);


