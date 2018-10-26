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


windowsSize = fix(audioInfo.TotalSamples/n_windows);


%*********************************************************
%***************   Enventanado    ************************
%*********************************************************
windowsSize = fix(audioInfo.TotalSamples/n_windows);

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
%**********   Decodificación        **********************
%*********************************************************

for WindowNum = 1:max(n_windows, currentWindowN)-1
  yx = windowsVectors(WindowNum, :);
  
  X = fft(yx);
  X_ln = log(X);
  X_ln_2 = X_ln .* X_ln;
  rxx = ifft(abs(X_ln_2));
  y = abs(rxx);
  
  ceroAmplitude1 = max(y(d_b0:d_b0+2));
  oneAmplitude1 = max(y(d_b1:d_b1+2));
  
  ceroAmplitude2 = y(d_b0+1);
  oneAmplitude2 = y(d_b1+1);
 
  if(ceroAmplitude1 < oneAmplitude1)
    bits1(WindowNum) = 1;
  else
    bits1(WindowNum) = 0;
  endif
  
  if(ceroAmplitude2 < oneAmplitude2)
    bits2(WindowNum) = 1;
  else
    bits2(WindowNum) = 0;
  endif
endfor

%*********************************************************
%**********   Error Rate        **********************
%*********************************************************
fid = fopen("..\\Codificador\\out.bin");
allbitsVector = fread(fid);
allbitsVector = allbitsVector';
fclose(fid);

fallo1 = 0;
acierto1 = 0;

fallo2 = 0;
acierto2 = 0;

TotalBits = length(allbitsVector);
for k = 1:TotalBits
  if allbitsVector(k) == bits1(k)
    acierto1++;
  else
    fallo1++;
  endif
  if allbitsVector(k) == bits2(k)
    acierto2++;
  else
    fallo2++;
  endif
endfor

errorRate1 = fallo1*100/TotalBits;
errorRate2 = fallo2*100/TotalBits;
printf("Error con dos muestras alrededor: %d\n", errorRate1);
printf("Error con una unica muestras: %d\n", errorRate2);


for currentCharIndex= 1:fix(length(bits1)/bitsPerChar)
 number = 0;
 for i = 1:bitsPerChar
  number += bits1(i+(bitsPerChar*(currentCharIndex-1)))*2**i;
 endfor
  result(currentCharIndex) = char(number);
  number = 0;
endfor

printf("El resultado obtenido es %s",result);